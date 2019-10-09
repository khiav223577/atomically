# frozen_string_literal: true

class UpdateAllScope
  AREL_SUPPORT_JOIN_TABLE = Gem::Version.new(Arel::VERSION) >= Gem::Version.new('10')

  def initialize(model: nil, relation: nil)
    @queries = []
    @relation = relation || model.class.where(id: model.id)
  end

  def where(*args)
    @relation = @relation.where(*args)
    return self
  end

  def update(query, *binding_values)
    args = binding_values.size > 0 ? [[query, *binding_values]] : [query]
    @queries << klass.send(:sanitize_sql_for_assignment, *args)
    return self
  end

  def do_query!
    return 0 if @queries.empty?
    return @relation.update_all(updates_as_string)
  end

  def updates_as_string
    @queries.join(',')
  end

  def klass
    @relation.klass
  end

  # See: https://github.com/rails/rails/blob/fc5dd0b85189811062c85520fd70de8389b55aeb/activerecord/lib/active_record/relation.rb#L315
  def to_arel
    if @relation.eager_loading?
      scope = UpdateAllScope.new(model: model, relation: @relation.apply_join_dependency)
      return scope.update(updates_as_string).to_update_manager
    end

    stmt = new_arel_update_manager

    stmt.set Arel.sql(klass.send(:sanitize_sql_for_assignment, updates_as_string))
    stmt.table(stmt_table)
    stmt.key = arel_attribute(@relation.primary_key)

    if should_use_join_to_update?
      join_to_update(klass.connection, stmt, stmt.key)
    else
      stmt.take(@relation.arel.limit)
      stmt.order(*@relation.arel.orders)
      stmt.wheres = @relation.arel.constraints
    end

    return stmt
  end

  def to_sql
    connection = klass.connection
    sql, binds = to_sql_and_binds(connection, to_arel)
    type_casted_binds(connection, binds).each_with_index{|var, idx| sql = sql.gsub("$#{idx + 1}", connection.quote(var)) }
    return sql
  end

  private

  def should_use_join_to_update?
    return false if AREL_SUPPORT_JOIN_TABLE
    return true if has_join_values?
    return true if @relation.offset_value
    return false
  end

  def stmt_table
    return @relation.table if not AREL_SUPPORT_JOIN_TABLE
    return @relation.arel.join_sources.empty? ? @relation.table : @relation.arel.source
  end

  def new_arel_update_manager
    return Arel::UpdateManager.new(ActiveRecord::Base) if Gem::Version.new(Arel::VERSION) < Gem::Version.new('7')
    return Arel::UpdateManager.new
  end

  def has_join_values?
    return @relation.send(:has_join_values?) if @relation.respond_to?(:has_join_values?, true)
    return true if @relation.joins_values.any?
    return true if @relation.respond_to?(:left_outer_joins_values) and @relation.left_outer_joins_values.any?
    return false
  end

  def arel_attribute(name)
    return @relation.arel_attribute(name) if @relation.respond_to?(:arel_attribute)
    name = klass.attribute_alias(name) if klass.respond_to?(:attribute_alias?) && klass.attribute_alias?(name) # attribute_alias? is not defined in Rails 3.
    return @relation.arel_table[name]
  end

  def to_sql_and_binds(connection, arel_or_sql_string)
    return connection.send(:to_sql_and_binds, arel_or_sql_string, []) if connection.respond_to?(:to_sql_and_binds, true)
    return [arel_or_sql_string.dup.freeze, []] if !arel_or_sql_string.respond_to?(:ast)
    sql, binds = accept(connection, arel_or_sql_string.ast)
    return [sql.freeze, (binds || []) + bind_values]
  end

  def accept(connection, ast)
    return connection.visitor.accept(ast) if not connection.respond_to?(:collector) # For Rails 3
    return connection.visitor.accept(ast, connection.collector).value
  end

  def type_casted_binds(connection, binds)
    return connection.type_casted_binds(binds) if connection.respond_to?(:type_casted_binds)
    return binds.map{|column, value| connection.type_cast(value, column) } if binds.first.is_a?(Array)
    return binds.map{|attr| connection.type_cast(attr.value_for_database) }
  end

  def join_to_update(connection, stmt, key)
    return connection.join_to_update(stmt, @relation.arel) if connection.method(:join_to_update).arity == 2
    return connection.join_to_update(stmt, @relation.arel, key)
  end

  def bind_values
    return @relation.bound_attributes if @relation.respond_to?(:bound_attributes) # For Rails 5.1, 5.2
    return @relation.bind_values # For Rails 4.2
  end
end
