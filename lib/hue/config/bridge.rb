module Hue
  module Config
    class Bridge < Abstract

      def self.file_path
        File.join(ENV['HOME'], ".#{Hue.device_type}", 'bridges.yml')
      end

      def self.find(id)
        yaml = read_file(file_path)
        entry = yaml.select { |k,v| k.to_s == id.to_s }
        if entry.empty?
          nil
        else
          new(id, entry[id]['uri'])
        end
      end

      public

      attr_accessor :uri

      def initialize(id, uri, path = self.class.file_path)
        super(id, path)
        @uri = uri
      end

      def id
        self.name
      end

      def write(overwrite_existing_key = true)
        super(overwrite_existing_key)
      end

      private

      def add_self_to_yaml(yaml)
        key = id.dup.force_encoding('ASCII')
        yaml[key] = {'uri' => self.uri.force_encoding('ASCII')}
      end

    end
  end
end
