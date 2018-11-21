class << ActiveRecord::Base
  if not method_defined?(:find_by)
    def find_by(*args)
      where(*args).order('').first
    end
  end
end
