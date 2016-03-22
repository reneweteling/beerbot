namespace :heroku do 

  task :app do 
    ENV["FROM_APP"] ||= 'beerbot-production'
    ENV["TO_APP"] ||= 'beerbot-dev'
    raise "Noooooo dont overwrite production!!" if ENV["TO_APP"] == 'beerbot-production'
  end
  
  task :capture => 'heroku:app' do  
    run_command "heroku pg:backups capture --app #{ENV["FROM_APP"]}"
  end

  task :reset_db => 'heroku:app' do  
    run_command "heroku pg:backups restore $(heroku pg:backups public-url --app #{ENV["FROM_APP"]}) DATABASE_URL --app #{ENV["TO_APP"]} --confirm #{ENV["TO_APP"]}"
    run_command "heroku run bin/rake db:migrate --app #{ENV["TO_APP"]}"
  end

  task :capture_and_reset_db => ['heroku:capture', 'heroku:reset_db']

  task :to_local => 'heroku:app' do
    run_command "wget -O heroku.dump $(heroku pg:backups public-url --app #{ENV["FROM_APP"]})"
    run_command "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d horyon_dev heroku.dump"
    run_command "rm heroku.dump"
  end

  def run_command(cmd)
    puts "Running: '#{cmd}'"
    puts `#{cmd}`
  end

end