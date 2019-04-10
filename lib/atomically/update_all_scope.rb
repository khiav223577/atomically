# frozen_string_literal: true

class UpdateAllScope
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
    stmt.table(@relation.table)

    if @relation.send(:has_join_values?) || @relation.offset_value
      klass.connection.join_to_update(stmt, @relation.arel, @relation.arel_attribute(@relation.primary_key))
    else
      stmt.key = @relation.arel_attribute(@relation.primary_key)
      stmt.take(@relation.arel.limit)
      stmt.order(*@relation.arel.orders)
      stmt.wheres = @relation.arel.constraints
    end

    return stmt
  end

  def to_sql
    connection = klass.connection
    sql, vars = connection.send(:to_sql_and_binds, to_arel, [])
    connection.type_casted_binds(vars).each_with_index{|var, idx| sql = sql.gsub("$#{idx + 1}", connection.quote(var)) }
    return sql
  end

  private

  def new_arel_update_manager
    return Arel::UpdateManager.new(ActiveRecord::Base) if Gem::Version.new(Arel::VERSION) < Gem::Version.new('7')
    return Arel::UpdateManager.new
  end
end
