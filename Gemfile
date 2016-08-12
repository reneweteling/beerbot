source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '4.2.7'
gem 'sass-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'slim-rails'
gem 'pg'

# autentication and authorisation
gem 'activeadmin', github: 'activeadmin'
gem 'rack-cors', :require => 'rack/cors'
gem 'cancancan', '~> 1.10'
gem 'devise'
gem 'devise-token_authenticatable'
gem 'mini_magick'

source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap-sass'
end

group :development do
  gem 'guard-livereload', '~> 2.4', require: false
  gem 'xray-rails'
  gem 'spring'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'shoulda-matchers'
  gem 'byebug'
end

group :test do
  gem 'database_cleaner'
end

group :production do 
  gem 'rails_12factor'
  gem 'appsignal', '~> 0.12.rc'
  gem 'puma'
end