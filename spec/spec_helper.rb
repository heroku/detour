require "active_record"
require "active_record/rollout"
require "shoulda-matchers"
require "generators/templates/migration"


RSpec.configure do |config|
  config.before :suite do
    ActiveRecord::Base.establish_connection \
      adapter: "sqlite3",
      database: File.dirname(__FILE__) + "/spec.sqlite3"

    require File.dirname(__FILE__) + "/support/schema.rb"
  end

  config.before :each do
    ActiveRecordRolloutMigration.migrate :up
    ActiveRecord::Schema.migrate :up
  end

  config.after :each do
    ActiveRecordRolloutMigration.migrate :down
    ActiveRecord::Schema.migrate :down
  end
end
