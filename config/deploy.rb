set :application, "pimon"
set :user, "pi"

set :scm, :git

set :repository, "git://github.com/pedrocarrico/pimon.git"

set :deploy_to, "/home/pi/app/pimon"
set :deploy_via, :remote_cache # quicker checkouts from github

set :domain, 'raspberrypi'
role :app, domain
role :web, domain

set :runner, user
set :use_sudo, false

namespace :deploy do
  task :start, :roles => [:web, :app] do
    deploy.check_basic_auth
    run "cd #{deploy_to}/current && nohup thin -C config/thin/config.yml -R config/config.ru start"
  end
  
  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C config/thin/config.yml -R config/config.ru stop"
  end
  
  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.check_basic_auth
    deploy.start
  end
  
  task :cold do
    deploy.update
    deploy.check_basic_auth
    deploy.start
  end
  
  desc "After deploying check if there's need for a new username/password for the basic_auth"
  task :check_basic_auth, :roles => :app do
    require "yaml"
    set :username, proc { Capistrano::CLI.ui.ask("username : ") }
    set :password, proc { Capistrano::CLI.password_prompt("password : ") }
    set :shared_config, "#{deploy_to}/shared/production.yml"
    
    if 'true' ==  capture("if [ -e #{shared_config} ]; then echo 'true'; fi").strip
      run "cp #{shared_config} #{deploy_to}/current/config/production.yml"
    else
      production_config = YAML::load_file('config/production.yml')
      production_config['basic_auth']['username'] = username
      production_config['basic_auth']['password'] = password
      
      put YAML::dump(production_config), shared_config, :mode => 0664
      run "cp #{shared_config} #{deploy_to}/current/config/production.yml"
      puts "DONE"
    end
  end
end