module Intercom
  module Rails
    class Configuration

      attr_reader :settings
      attr_reader :user
      attr_reader :company

      def initialize( context, &block )
        @user = Intercom::Rails::Proxy.new(context)
        @company = Intercom::Rails::Proxy.new(context)
        @enabled = proc { false } # we don't want to accidentally send data
        @settings = {}

        block.arity > 0 ? block.call(self) : instance_eval(&block)
      end

      # Configure settings
      #
      # @example
      #   set :app_id, 'my-app-id'
      def set( key, value = nil, &block )
        @settings[key] = value.nil? ? block.call : value
      end

      # enable/disable the configuration
      #
      # @example
      #   enabled { Rails.env.development? || Rails.env.production? }
      def enabled( &block )
        @enabled = block
      end

      # @private
      def enabled?
        @enabled.call
      end

    end
  end
end

