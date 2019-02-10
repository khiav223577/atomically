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
    return @relation.update_all(@queries.join(','))
  end

  def klass
    @relation.klass
  end

  # See: https://github.com/rails/rails/blob/fc5dd0b85189811062c85520fd70de8389b55aeb/activerecord/lib/active_record/relation.rb#L315
  def to_update_manager
    stmt = Arel::UpdateManager.new

    stmt.set Arel.sql(@queries.join(','))
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
    to_update_manager.to_sql
  end
end
