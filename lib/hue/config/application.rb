module Hue
  module Config
    class Application < Abstract

      STRING_DEFAULT = 'default'
      STRING_BASE_URI = 'base_uri'
      STRING_IDENTIFIER = 'identifier'

      def self.file_path
        File.join(ENV['HOME'], ".#{Hue.device_type}", 'applications.yml')
      end

      def self.default
        named(STRING_DEFAULT)
      end

      def self.named(name)
        yaml = read_file(file_path)
        if named_yaml = yaml[name]
          new(named_yaml[STRING_BASE_URI], named_yaml[STRING_IDENTIFIER], name)
        else
          raise NotFound.new("Config named '#{name}' not found.")
        end
      end

      public

      attr_reader :base_uri, :identifier, :name

      def initialize(base_uri, identifier, name = STRING_DEFAULT)
        @base_uri = base_uri
        @identifier = identifier
        super(name, self.class.file_path)
      end

      def ==(rhs)
        super(rhs) &&
          self.base_uri == rhs.base_uri &&
          self.identifier == rhs.identifier
      end

      private

      def add_self_to_yaml(yaml)
        yaml[name] = {
          STRING_BASE_URI => self.base_uri,
          STRING_IDENTIFIER => identifier.force_encoding('ASCII') # Avoid binary encoded YAML
        }
      end

      def self.read_file(config_file)
        begin
          yaml = YAML.load_file(config_file)
        rescue => err
          raise Error.new("Failed to read configuration file", err)
        end
      end

    end
  end
end
