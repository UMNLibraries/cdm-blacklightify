# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

set :application, 'umedia'
set :deploy_user, 'uldeploy'
set :app_user, 'ulapps'

server 'umedia-publicdev.lib.umn.edu', user: fetch(:deploy_user), roles: %w{app db web}
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}

set :deploy_to, "/var/www/#{fetch(:application)}"
# Geoblacklight development server is in production mode to stay identical to prod!
set :rails_env, 'publicdev'

set :linked_files, [".env.#{fetch(:rails_env, 'production')}"]
# Geoblacklight development Solr URL with user/password

## Database configuration (NOT YET USED, copy/paste from geoportal)
#set :umedia_db_host, 'umedia-pg-dev.ccj1akonnqjd.us-east-2.rds.amazonaws.com'
#set :umedia_db_database, 'umedia_development'
#set :umedia_db_user, ->{`#{fetch(:lastpass_cmd)} --username #{fetch(:lastpass_root)}/dev/umedia_postgresql`.chomp }
#set :umedia_db_pass, ->{`#{fetch(:lastpass_cmd)} --password #{fetch(:lastpass_root)}/dev/umedia_postgresql`.chomp }
