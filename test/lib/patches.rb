# frozen_string_literal: true

require 'pluck_all'

class << ActiveRecord::Base
  if not method_defined?(:find_by)
    def find_by(*args)
      where('').find_by(*args)
    end
  end

  def pluck(*args)
    pluck_array(*args)
  end
end

class ActiveRecord::Relation
  if not method_defined?(:find_by)
    def find_by(*args)
      where(*args).order('').first
    end
  end

  def pluck(*args)
    pluck_array(*args)
  end
end
