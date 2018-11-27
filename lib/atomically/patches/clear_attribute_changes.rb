module ActiveModel
  module Dirty
    private

    alias_method :attributes_changed_by_setter, :changed_attributes # :nodoc:

    # Force an attribute to have a particular "before" value
    def set_attribute_was(attr, old_value)
      attributes_changed_by_setter[attr] = old_value
    end

    # Remove changes information for the provided attributes.
    def clear_attribute_changes(attributes) # :doc:
      attributes_changed_by_setter.except!(*attributes)
    end
  end
end
