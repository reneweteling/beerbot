namespace :heroku do 

  task :capture do  
    run_command "heroku pg:backups capture --app beerbot-dev"
  end

  task :to_local do
    run_command "wget -O heroku.dump $(heroku pg:backups public-url --app beerbot-dev)"
    run_command "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d beerbot_dev heroku.dump"
    run_command "rm heroku.dump"
  end

  def run_command(cmd)
    puts "Running: '#{cmd}'"
    puts `#{cmd}`
  end

end