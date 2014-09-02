# Load the Rails application.
require File.expand_path('../application', __FILE__)

ActiveRecord::Base.pluralize_table_names=false

# Initialize the Rails application.
Rails.application.initialize!
