
class BaseModel
  plugin :timestamps, update_on_create: true

  def self.inherited(subclass)
    super
    subclass.set_dataset(subclass.table_name) if subclass.respond_to?(:table_name)
  end

  def self.table_name
    raise NotImplementedError, "Subclasses must implement a table_name method"
  end

  def validate
    super
    set_validations
  end

  def assert(key, message)
    errors.add(key, message) unless yield
  end
end