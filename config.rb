module Hue
  class Config
    DEFAULT_CONFIG_NAME = 'default'

    require 'yaml'
    require 'fileutils'

    def self.bridges_config_path
      File.join(ENV['HOME'], ".#{APP_NAME}", 'bridges.yml')
    end

    def self.read(config_file = bridges_config_path)
      begin
        yaml = YAML.load_file(config_file)
      rescue => err
        raise Error.new("Failed to read configuration file", err)
      end
    end

    def self.default
      yaml = read
      if default_yaml = yaml[DEFAULT_CONFIG_NAME]
        Config.new(default_yaml[:base_uri], default_yaml[:identifier])
      else
        raise Error.new("Default config not found")
      end
    end

    public

    attr_reader :base_uri, :identifier, :name

    def initialize(base_uri, identifier, name = DEFAULT_CONFIG_NAME)
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
          :base_uri => self.base_uri,
          :identifier => identifier.force_encoding('ASCII') # Avoid binary encoded YAML
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

    private

    def self.setup_config_path(path)
      dir = File.dirname(path)
      puts dir
      FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
    end

  end
end
