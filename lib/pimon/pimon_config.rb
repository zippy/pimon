require 'pimon/hash_extensions'
require 'yaml'

class PimonConfig
  def self.create_new(filename)
    return self.new(filename)
  end
  
  def chart
    @config[:chart]
  end
  
  def stats
    @config[:stats_collector]
  end
  
  private
  
  def initialize(filename)
    begin
      @config = YAML.load_file(filename).symbolize_keys
      @config.freeze
    rescue Exception => e
      puts "Error while loading config file: #{filename}"
      raise e
    end
  end
end
