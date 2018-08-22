# require project gems
require 'bundler/setup'
Bundler.require(:default, Kimurai.env)

# require custom ENV variables located in .env file
require 'dotenv/load'

# require initializers
Dir.glob(File.join("./config/initializers", "*.rb"), &method(:require))

# require helpers
Dir.glob(File.join("./helpers", "*.rb"), &method(:require))

# require pipelines
Dir.glob(File.join("./pipelines", "*.rb"), &method(:require))

# require spiders recursively in the `spiders/` folder
require_relative '../spiders/application_spider'
require_all "spiders"

# require Kimurai configuration
require_relative 'application'
