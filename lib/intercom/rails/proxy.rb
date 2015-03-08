module Intercom
  module Rails
    class Proxy

      def initialize( context )
        @context = context

        @instance = proc {}
        @attributes = proc {}
        @reject = proc { false } # allow by default
      end

      # Set the instance for the proxy
      #
      # @example
      #   instance { |context| context.current_user }
      def instance( &block )
        @instance = block
      end

      # Set the pattern for rejection of instances
      #
      # @example
      #   reject { |instance| instance.deleted? }
      def reject( &block )
        @reject = block
      end

      # Set the attributes for the instance to return
      #
      # @example
      #   attributes do |instance|
      #     {
      #       id: instance.uuid
      #     }
      #   end
      #
      # @example additionally fetching stuff fomr the controller
      #   attributes do |instance, context|
      #     {
      #       id: instance.uuid,
      #       monthly_spend: context.monthly_spend
      #     }
      #   end
      def attributes( &block )
        @attributes = block
      end

      # @private
      def present?
        to_h.present?
      end

      # @private
      def to_h
        return @_attributes if defined?(@_attributes)

        _instance = @instance.call(@context)
        @_attributes = @attributes.call(_instance, @context)
      end

    end
  end
end
