$LOAD_PATH.unshift '.'

require 'resque/tasks'
require 'resque/scheduler/tasks'

task 'resque:setup' => 'emerald:environment'
task 'resque:scheduler' => 'resque:setup'

namespace :emerald do
  desc 'Spawns an interactive console'
  task :console => :environment do |t|
    interactive_ruby = ENV.fetch('INTERACTIVE_RUBY', 'pry')
    exec "bundle exec #{ interactive_ruby } -I. -r config/boot"
  end

  desc 'Setup environment'
  task :environment do
    require 'config/boot'
  end
end

# namespace :db do
#   desc "Run migrations"
#   task :migrate, [:version] do |t, args|
#     # Don't load models when executing DB migrations.
#     # This is required, since some of the tables they refer to might not exist
#     # yet. It also prevents accidentally using them within migrations - which
#     # is asking for trouble anyway.
#     ENV['EMERALD_SKIP_MODELS'] = '1'
#     require 'config/boot'
# 
#     logger = Emerald.logger(program: 'migrations')
# 
#     Sequel.extension :migration
#     db = Sequel::Model.db
#     if args[:version]
#       logger.info "Migrating to version #{args[:version]}"
#       Sequel::Migrator.run(db, "db/migrations", target: args[:version].to_i)
#     else
#       logger.info "Migrating to latest"
#       Sequel::Migrator.run(db, "db/migrations")
#     end
#   end
# 
#   desc 'Drop and recreate database'
#   task :recreate do |t|
#     ENV['EMERALD_SKIP_MODELS'] = '1'
#     require 'config/boot'
# 
#     logger = Emerald.logger(program: 'migrations')
# 
#     application_db = Emerald::Config::Database::DATABASE
#     # Reassigning a constant is a bit ugly - but less ugly than duplicating
#     # `config/database.rb` for the purpose of getting a DB instance to work
#     # with.
#     Emerald::Config::Database::DATABASE = 'postgres'
#     db = Emerald::Config::Database.database
# 
#     # Terminate existing connnections.
#     Sequel::Model.db.disconnect
#     logger.info "Resetting database #{ application_db }"
#     db.execute("DROP DATABASE #{ application_db }")
#     db.execute("CREATE DATABASE #{ application_db }")
#   end
# 
#   desc 'Reset database and apply all migrations'
#   task :reset => :recreate do |t|
#     ENV['EMERALD_SKIP_MODELS'] = '1'
#     require 'config/boot'
# 
#     logger = Emerald.logger(program: 'migrations')
# 
#     Sequel.extension :migration
#     logger.info 'Migrating to latest'
#     Sequel::Migrator.run(Sequel::Model.db, "db/migrations")
#   end
# end

namespace :spec do
  begin
    require 'rspec/core/rake_task'

    RSpec::Core::RakeTask.new(:all) do |t|
      t.fail_on_error = false
      t.rspec_opts = '--format doc'
    end

    RSpec::Core::RakeTask.new(:importer) do |t|
      t.fail_on_error = false
      t.pattern       = 'spec/emerald/importer/**/*_spec.rb'
      t.rspec_opts = '--format doc'
    end

    RSpec::Core::RakeTask.new(:models) do |t|
      t.fail_on_error = false
      t.pattern       = 'spec/emerald/models/**/*_spec.rb'
      t.rspec_opts = '--format doc'
    end

    RSpec::Core::RakeTask.new(:feature) do |t|
      t.fail_on_error = false
      t.pattern       = 'spec/feature/**/*_spec.rb'
      t.rspec_opts = '--format doc'
    end
  rescue LoadError
    # no rspec available
  end
end
