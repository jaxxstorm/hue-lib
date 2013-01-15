module Hue
  class Config
    class NotFound < Hue::Error; end;

    STRING_DEFAULT = 'default'
    STRING_BASE_URI = 'base_uri'
    STRING_IDENTIFIER = 'identifier'

    require 'yaml'
    require 'fileutils'

    def self.bridges_config_path
      File.join(ENV['HOME'], ".#{Hue.device_type}", 'bridges.yml')
    end

    def self.default
      named(STRING_DEFAULT)
    end

    def self.named(name)
      yaml = read_file
      if named_yaml = yaml[name]
        Config.new(named_yaml[STRING_BASE_URI], named_yaml[STRING_IDENTIFIER], name)
      else
        raise NotFound.new("Config named '#{name}' not found.")
      end
    end

    public

    attr_reader :base_uri, :identifier, :name

    def initialize(base_uri, identifier, name = STRING_DEFAULT)
      @base_uri = base_uri
      @identifier = identifier
      @name = name
    end

    def write(config_file = self.class.bridges_config_path)
      yaml = YAML.load_file(self.class.bridges_config_path) rescue Hash::New
      if yaml.key?(name)
        raise "Configuration named '#{name}' already exists in #{config_file}\nPlease de-register before creating a new one with the same name."
      else
        yaml[name] = {
          STRING_BASE_URI => self.base_uri,
          STRING_IDENTIFIER => identifier.force_encoding('ASCII') # Avoid binary encoded YAML
        }
        self.class.setup_config_path(config_file)
        File.open(config_file, 'w+' ) do |out|
          YAML.dump(yaml, out)
        end
      end
    end

    def delete
      config_file = self.class.bridges_config_path
      yaml = YAML.load_file(config_file) rescue Hash::New

      if yaml.key?(name)
        yaml.delete(name)
      end

      if yaml.size > 0
        self.class.setup_config_path(config_file)
        File.open(config_file, 'w+' ) do |out|
          YAML.dump(yaml, out)
        end
      end
    end

    def ==(rhs)
      lhs = self

      lhs.class == rhs.class &&
        lhs.name == rhs.name &&
        lhs.base_uri == rhs.base_uri &&
        lhs.identifier == rhs.identifier
    end

    private

    def self.setup_config_path(path)
      dir = File.dirname(path)
      FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
    end

    def self.read_file(config_file = bridges_config_path)
      begin
        yaml = YAML.load_file(config_file)
      rescue => err
        raise Error.new("Failed to read configuration file", err)
      end
    end

  end
end
