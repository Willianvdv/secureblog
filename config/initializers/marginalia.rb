ActiveSupport.on_load :active_record do
  require './lib/party'

  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.module_eval do
    include Party::ActiveRecordInstrumentation
  end
end
