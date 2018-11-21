require 'active_record'

class ActiveRecord::Relation
  def atomically
  end
end

class ActiveRecord::Base
  def self.atomically
  end
end
