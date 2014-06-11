web: bundle exec puma --config config/puma.rb config.ru
clock: bundle exec clockwork clock.rb
hk_worker: bundle exec sidekiq -q hk_worker -g ${DYNO:-hk_worker} -i ${DYNO:-1} -r ./lib/initializer.rb -c 5
