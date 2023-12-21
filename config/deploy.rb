set :application, 'umedia'
set :repo_url, 'git@github.com:UMNLibraries/cdm-blacklightify.git'

# Default branch is :main
# Prompt to choose a tag (or name a branch), default to last listed tag
# unless an environment variable was passed on the command line as in:
# $ GEOBLACKLIGHT_RELEASE=1.0.0 bundle exec cap development deploy
unless ARGV.include?('deploy:rollback')
  avail_tags = `git ls-remote --sort=version:refname --refs --tags git@github.com:UMNLibraries/cdm-blacklightify.git | cut -d/ -f3-`
  set :branch, (ENV['UMEDIA_RELEASE'] || ask("release tag or branch:\n #{avail_tags}", avail_tags.chomp.split("\n").last))
end

# Ruby is installed by ansible
set :ruby_version, '3.0.3'
set :deploy_user, 'uldeploy'
set :app_user, 'ulapps'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/swadm/var/www/#{fetch(:application)}"

# LastPass CLI command
set :lastpass_cmd, '/usr/bin/env lpass show'
set :lastpass_root, 'Shared-umedia'

# Common lastpass vars
# The lambdas ->{...} ensure these only invoke lpass at call time becausse only setup tasks need them

# Forces crontab surrounding comments to include deploy target
#set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:rails_env)}"}

#set :whenever_variables, ->{ "'environment=#{fetch :whenever_environment}&ruby=/opt/ruby-versions/#{fetch(:ruby_version)}/bin'" }
# Need sudo for whenever to be able to set crontab for the app user while deploying as app user
# And assumes whenever gem preinstalled
#set :whenever_update_flags, ->{ " --crontab-command 'sudo -u #{fetch(:app_user)} /usr/bin/crontab' --update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}" }

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
#set :linked_files, fetch(:linked_files, []).push('config/blacklight.yml', 'config/database.yml', 'config/solr.yml', 'config/secrets.yml')
set :linked_files, [".env.#{fetch(:rails_env, 'production')}"]

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'storage', 'tmp/pids', 'tmp/cache', 'public/system', 'public/uploads', 'node_modules', 'db/pub')

# tmp directory is user-specific
set :tmp_dir, "/tmp/#{fetch(:deploy_user)}"

# Put requested ruby version into PATH
set :default_env, { path: "/opt/ruby-versions/#{fetch(:ruby_version)}/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :setup do
  # Because we use linked_files for .env.<stage>, Capistrano would check for this file's presence
  # on its own and throw an error, but we have a custom task so that we can provide our own exception
  # message with instructions on how to proceed.
  desc 'Check that dotenv secrets file exists'
  task :secrets_exists do
    on roles(:app) do
      if !test("test -f #{shared_path}/.env.#{fetch(:rails_env, 'production')}")
        raise Capistrano::ValidationError.new("Secrets file .env.#{fetch(:rails_env, 'production')} has not been created. Run 'cap <environment> setup:secrets' before deploy")
      end
      # No error, so everything is fine
      info "Success: #{shared_path}/.env.#{fetch(:rails_env, 'production')} exists"
    end
  end

  desc 'Create dotenv secrets files'
  task :secrets do
    on roles(:app) do
      # Bail out if lastpass is not logged in
      if `/usr/bin/env lpass status`.chomp =~ /^Not logged in/
        raise Capistrano::ValidationError.new('Please log into LastPass via `lpass login` before continuing')
      end

      # dotenv file for rails_env, swadm owned, 640
      template 'template.env', "#{shared_path}/.env.#{fetch(:rails_env, 'production')}", '0640', fetch(:deploy_user), fetch(:app_user)
      # Symlink the dotfile to a regular file, so it appears when lazily ls'ing the shared/ dir
      execute 'ln', '-sf', "#{shared_path}/.env.#{fetch(:rails_env, 'production')}", "#{shared_path}/env.#{fetch(:rails_env, 'production')}"
    end
  end
end

namespace :deploy do
  desc 'Create storage dir'
  task :create_storage_dir do
    on roles(:app) do
      execute :mkdir, '-p', "#{shared_path}/storage"
      execute :chown, "#{fetch(:deploy_user)}:#{fetch(:app_user)}", "#{shared_path}/storage"
      execute :chmod, '2775', "#{shared_path}/storage"
    end
  end

  desc 'Fix permissions on existing assets'
  task :prepare_cache_dir do
    on roles(:app) do
      execute :mkdir, '-p', "#{shared_path}/tmp/cache/downloads"
      execute :sudo, "chown -R #{fetch(:deploy_user)}:#{fetch(:app_user)}", "#{shared_path}/tmp/cache"
      execute :sudo, "chmod -R g+w #{shared_path}/tmp/cache"
    end
  end

  desc 'Prepare Universal Viewer in public docroot'
  task :universal_viewer do
    on roles(:app) do
      within release_path do
        execute './prep_uv.sh'
      end
    end
  end


  after 'deploy:symlink:release', :clear_cache do
    on roles(:app) do
      # Here we can do anything such as:
      within release_path do
        # Restart the puma services, rolling worker restart
        #execute :sudo, 'systemctl reload puma-geoportal'
        # Revert to full restart. Sometimes some code doesn't fully reload on the soft
        # worker restarts. More downtime but more reliable code.
        execute :sudo, 'systemctl restart puma-umedia'
        execute :sudo, 'systemctl status --no-pager puma-umedia'

        # Refresh the Google/Crawler Sitemap
        # execute :rake, 'sitemap:refresh', "RAILS_ENV=#{fetch(:rails_env)}"

        # Stop and Restart Sidekiq
        execute :sudo, 'systemctl restart sidekiq'
      end
    end
  end
end

before 'deploy:starting', 'setup:secrets_exists'
before 'deploy:compile_assets', 'deploy:prepare_cache_dir'
before 'deploy:symlink:shared', 'deploy:create_storage_dir'
before  'deploy:symlink:release', 'deploy:universal_viewer'
