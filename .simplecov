# SimpleCov configuration file
# This provides a cleaner alternative to configuring SimpleCov in spec_helper.rb

SimpleCov.configure do
  # Basic filters
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/test/'

  # Group coverage by component
  add_group 'Core', 'core'
  add_group 'Extensions', 'extensions'
  add_group 'Modules', 'modules'

  # Track files based on coverage focus
  if ENV['COVERAGE'] == 'core'
    track_files 'core/**/*.rb'
  elsif ENV['COVERAGE'] == 'extensions'
    track_files 'extensions/**/*.rb'
  elsif ENV['COVERAGE'] == 'modules'
    track_files 'modules/**/*.rb'
  else
    # Default: track everything
    track_files '{core,extensions,modules}/**/*.rb'
  end

  # Coverage thresholds
  minimum_coverage 80 if ENV['CI']

  # Formatters
  formatter SimpleCov::Formatter::HTMLFormatter
end