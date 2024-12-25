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

  case File.extname(file_path)
  when '.rb', '.js'
    content = File.read(file_path)
    if content.include?(old_copyright)
      updated_content = content.gsub(old_copyright, new_copyright)
      File.write(file_path, updated_content)
      @log.info("Updated copyright in #{file_path}")
      @log_file_logger.info("Updated copyright in #{file_path}")
    else
      @log.warn("Copyright string not found in #{file_path}")
      @log_file_logger.warn("Copyright string not found in #{file_path}")
    end
  when '.yaml'
    yaml_content = YAML.load_file(file_path)
    if yaml_content && yaml_content['copyright'] == old_copyright
      yaml_content['copyright'] = new_copyright
      File.write(file_path, yaml_content.to_yaml)
      @log.info("Updated copyright in YAML file: #{file_path}")
      @log_file_logger.info("Updated copyright in YAML file: #{file_path}")
    else
      @log.warn("Copyright string not found or incorrect in YAML file: #{file_path}")
      @log_file_logger.warn("Copyright string not found or incorrect in YAML file: #{file_path}")
    end
when '.html'
    content = File.read(file_path)
    if content.include?(old_copyright)
      updated_content = content.gsub(old_copyright, new_copyright)
      File.write(file_path, updated_content)
      @log.info("Updated copyright in HTML file: #{file_path}")
      @log_file_logger.info("Updated copyright in HTML file: #{file_path}")
    else
      @log.warn("Copyright string not found in HTML file: #{file_path}")
      @log_file_logger.warn("Copyright string not found in HTML file: #{file_path}")
    end
  end
rescue => e
  @log.error("Error processing file #{file_path}: #{e.message}")
  @log_file_logger.error("Error processing file #{file_path}: #{e.message}")
end

old_copyright = 'Copyright (c) 2006-2024'
new_copyright = 'Copyright (c) 2006-2025'

Dir.glob("../../**/*.{rb,js,yaml,html}").each do |file|
  update_copyright(file, old_copyright, new_copyright)
end

@log.info("Copyright update process completed.")
@log_file_logger.info("Copyright update process completed.")
log_file.close