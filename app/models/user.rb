class User < ApplicationRecord
  self.ignored_columns = [:something]
end
