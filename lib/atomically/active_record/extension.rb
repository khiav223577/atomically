# frozen_string_literal: true

require 'active_record'
require 'atomically/query_service'

class ActiveRecord::Relation
  def atomically
    Atomically::QueryService.new(klass, relation: self)
  end
end

class ActiveRecord::Base
  def self.atomically
    Atomically::QueryService.new(self)
  end

  def atomically
    Atomically::QueryService.new(self.class, model: self)
  end
end
