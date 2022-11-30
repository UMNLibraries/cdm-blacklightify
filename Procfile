redis:       bin/redis-wrapper
# Raise concurrency with env
sidekiq:     bundle exec sidekiq -q devise,1 -q default,2 -q critical,3 -c $SIDEKIQ_CONCURRENCY
# sidekiq_web: bundle exec puma sidekiq.ru
solr:        bundle exec solr_wrapper --config .solr_wrapper.yml
puma:        bundle exec rails server -p 3000 -b 127.0.0.1
