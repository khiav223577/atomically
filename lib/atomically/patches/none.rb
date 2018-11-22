require 'active_record'

class << ActiveRecord::Base
  def none # For Rails 3
    where('1=0')
  end
end
