namespace :pg do
  desc "Drop the postgresql connections"
  task :disconnect do
    conf = Rails.configuration.database_configuration[Rails.env]
    return unless conf['adapter'] == 'postgresql'
    system("psql postgres -c \"select pg_terminate_backend(pid) from pg_stat_activity where datname='#{conf['database']}'\"")
  end
end

namespace :db do 
  desc "Reseed"
  task :reseed => %w(pg:disconnect db:drop db:create db:migrate db:seed) unless Rails.env.production?
end