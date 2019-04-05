class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.ignored_columns = [:some_fake_attribute_to_force_column_references]
end
