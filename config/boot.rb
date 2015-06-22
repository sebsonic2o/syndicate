ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# Import environment variables when dotenv is available
if Gem::Specification.find_all_by_name('dotenv').any?
  require 'dotenv'
  Dotenv.load ".env"
end
