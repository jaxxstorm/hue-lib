module Hue
  module Config
    class Application < Abstract

      STRING_BASE_ID = 'base_id'
      STRING_DEFAULT = 'default'
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
          new(named_yaml[STRING_BASE_ID], named_yaml[STRING_IDENTIFIER], name)
        else
          raise NotFound.new("Config named '#{name}' not found.")
        end
      end

      public

      attr_reader :base_id, :identifier, :name

      def initialize(base_id, identifier, name = STRING_DEFAULT, path = self.class.file_path)
        super(name, path)
        @base_id = base_id
        @identifier = identifier
      end

      def ==(rhs)
        super(rhs) &&
          self.base_id == rhs.base_id &&
          self.identifier == rhs.identifier
      end

      private

      def add_self_to_yaml(yaml)
        key = self.name.dup.force_encoding('ASCII') # Avoid binary encoded YAML
        base = base_id.dup.force_encoding('ASCII')
        yaml[key] = {
          STRING_BASE_ID => base,
          STRING_IDENTIFIER => identifier.force_encoding('ASCII')
        }
      end

    end
  end
end
