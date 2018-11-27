# frozen_string_literal: true

require 'active_record'

class << ActiveRecord::Base
  def from(value) # For Rails 3
    value = "(#{value.to_sql}) subquery" if value.is_a?(ActiveRecord::Relation)
    return super
  end
end
