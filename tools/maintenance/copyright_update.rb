require 'yaml'
require 'logger'

# Set up logging
@log = Logger.new(STDOUT)
@log.level = Logger::INFO
log_file = File.open('copyright_update.log', 'w')
@log_file_logger = Logger.new(log_file)
@log_file_logger.level = Logger::INFO

def update_copyright(file_path, copyright_pattern, new_copyright)
  @log.info("Processing file: #{file_path}")
  @log_file_logger.info("Processing file: #{file_path}")

  content = File.read(file_path)
  if content.empty?
    @log.info("File is empty, no copyright update needed: #{file_path}")
    @log_file_logger.info("File is empty, no copyright update needed: #{file_path}")
  elsif content.match?(copyright_pattern)
    updated_content = content.gsub(copyright_pattern, "\\1#{new_copyright}")
    if updated_content != content
      File.write(file_path, updated_content)
      @log.info("Updated copyright in #{file_path}")
      @log_file_logger.info("Updated copyright in #{file_path}")
    end
  else
    @log.warn("Copyright pattern not found in #{file_path}")
    @log_file_logger.warn("Copyright pattern not found in #{file_path}")
  end
rescue => e
  @log.error("Error processing file #{file_path}: #{e.message}")
  @log_file_logger.error("Error processing file #{file_path}: #{e.message}")
end

# Regex to match "Copyright (c) 2006-YYYY" or "(C) 2006-YYYY"
# Captures the prefix so we can replace only the year part if needed, 
# or better yet, replace the whole match but preserve the "Copyright (c)" part.
copyright_pattern = /((?:Copyright \(c\) |\(C\) )2006-)20\d{2}/
new_year = '2026'

Dir.glob("../../**/*.{rb,js,yaml,html,md,txt,css,c,nasm,java,php,as}").each do |file|
  next if File.basename(file) == 'copyright_update.rb'
  update_copyright(file, copyright_pattern, new_year)
end

# Handle files without extensions, excluding copyright_update.rb
Dir.glob("../../**/*").reject { |f| 
  File.directory?(f) || File.extname(f) != '' || File.basename(f) == 'copyright_update.rb'
}.each do |file|
  update_copyright(file, copyright_pattern, new_year)
end

@log.info("Copyright update process completed.")
@log_file_logger.info("Copyright update process completed.")
log_file.close