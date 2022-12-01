redis:       bin/redis-wrapper
# Raise concurrency with env (default 5 but 15 can really get it cooking)
sidekiq:     bundle exec sidekiq -q devise,1 -q default,2 -c ${SIDEKIQ_CONCURRENCY:-5} -q critical,3
# sidekiq_web: bundle exec puma sidekiq.ru
solr:        bundle exec solr_wrapper --config .solr_wrapper.yml
puma:        bundle exec rails server -p 3000 -b 127.0.0.1
