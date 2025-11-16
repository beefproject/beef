require 'yaml'
require 'logger'

# Set up logging
@log = Logger.new(STDOUT)
@log.level = Logger::INFO
log_file = File.open('copyright_update.log', 'w')
@log_file_logger = Logger.new(log_file)
@log_file_logger.level = Logger::INFO

def update_copyright(file_path, old_copyright, new_copyright)
  @log.info("Processing file: #{file_path}")
  @log_file_logger.info("Processing file: #{file_path}")

  # Treat all files the same way for copyright update, including YAML and CSS
  content = File.read(file_path)
  if content.empty?
    @log.info("File is empty, no copyright update needed: #{file_path}")
    @log_file_logger.info("File is empty, no copyright update needed: #{file_path}")
  else
    if content.include?(old_copyright)
      updated_content = content.gsub(old_copyright, new_copyright)
      File.write(file_path, updated_content)
      @log.info("Updated copyright in #{file_path}")
      @log_file_logger.info("Updated copyright in #{file_path}")
    else
      @log.warn("Copyright string not found in #{file_path}")
      @log_file_logger.warn("Copyright string not found in #{file_path}")
    end
  end
rescue => e
  @log.error("Error processing file #{file_path}: #{e.message}")
  @log_file_logger.error("Error processing file #{file_path}: #{e.message}")
end

old_copyright = 'Copyright (c) 2006-2024'
new_copyright = 'Copyright (c) 2006-2025'

Dir.glob('../../**/*.{rb,js,yaml,html,md,txt,css,c,nasm,java,php,as}').each do |file|
  next if File.basename(file) == 'copyright_update.rb'  # Skip this file

  update_copyright(file, old_copyright, new_copyright)
end

# Handle files without extensions, excluding copyright_update.rb
Dir.glob('../../**/*').reject { |f| 
  File.directory?(f) || File.extname(f) != '' || File.basename(f) == 'copyright_update.rb'
}.each do |file|
  update_copyright(file, old_copyright, new_copyright)
end

@log.info('Copyright update process completed.')
@log_file_logger.info('Copyright update process completed.')
log_file.close