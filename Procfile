redis:       bin/redis-wrapper
# Raise concurrency with env (default 5 but 15 can really get it cooking)
sidekiq:     bundle exec sidekiq --concurrency ${SIDEKIQ_CONCURRENCY:-5} --config=config/sidekiq.yml
# sidekiq_web: bundle exec puma sidekiq.ru
solr:        bundle exec solr_wrapper --config .solr_wrapper.yml
puma:        bundle exec rails server -p 3000 -b 127.0.0.1
