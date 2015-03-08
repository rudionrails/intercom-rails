require "singleton"

module Intercom
  module Rails
    class Repository
      include Singleton

      attr_reader :table

      def initialize
        @table = {}
      end

      def self.[]=( klass, value )
        instance.table[klass] = value
      end

      def self.[]( klass )
        configuration = instance.table[klass]

        if configuration.nil? && klass.respond_to?(:superclass)
          return Intercom::Rails::Repository[klass.superclass]
        end

        configuration
      end

    end
  end
end

