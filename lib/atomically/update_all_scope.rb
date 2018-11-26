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
end
