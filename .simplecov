# SimpleCov configuration file
# This provides a cleaner alternative to configuring SimpleCov in spec_helper.rb

SimpleCov.configure do
  # Basic filters
  skip '/spec/'
  skip '/config/'
  skip '/test/'

  # Group coverage by component
  group 'Core', 'core'
  group 'Extensions', 'extensions'
  group 'Modules', 'modules'

  # Track files based on coverage focus
  if ENV['COVERAGE'] == 'core'
    cover 'core/**/*.rb'
  elsif ENV['COVERAGE'] == 'extensions'
    cover 'extensions/**/*.rb'
  elsif ENV['COVERAGE'] == 'modules'
    cover 'modules/**/*.rb'
  else
    # Default: track everything
    cover '{core,extensions,modules}/**/*.rb'
  end

  # Coverage thresholds
  minimum_coverage 80 if ENV['CI']

  # Formatters
  formatter SimpleCov::Formatter::HTMLFormatter
end