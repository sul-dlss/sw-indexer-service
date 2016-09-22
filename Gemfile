source 'https://rubygems.org'

gem 'base_indexer', '~> 3.0'
gem 'discovery-indexer', '~> 3.0', '>= 3.0.1'

gem 'rails', '~> 4.2'
gem 'responders', '~> 2.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'config'

gem 'honeybadger', '~> 2.0'
gem 'okcomputer' # for monitoring

gem 'rubocop', group: [:development, :test]
gem 'rubocop-rspec', group: [:development, :test]

group :test do
  gem 'rspec-rails'
  gem 'equivalent-xml'
  gem 'coveralls', require: false
  gem 'webmock'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'dlss-capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
end
