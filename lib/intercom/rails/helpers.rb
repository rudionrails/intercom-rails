module Intercom
  module Rails
    module Helpers
      include ActiveSupport::Concern

      def self.included( base )
        base.helper_method :intercom_script_tag
        base.after_filter :__intercom_javascript, if: :__intercom?
      end


      private

      # Generate an intercom script tag.
      #
      # @param user_details [Hash] a customizable hash of user details
      # @param options [Hash] an optional hash for secure mode and widget customisation
      #
      # @option user_details [String] :app_id Your application id
      # @option user_details [String] :user_id unique id of this user within your application
      # @option user_details [String] :email email address for this user
      # @option user_details [String] :name the users name, _optional_ but useful for identify people in the Intercom App.
      # @option user_details [Hash] :custom_data custom attributes you'd like saved for this user on Intercom.
      # @option options [String] :widget a hash containing a css selector for an element which when clicked should show the Intercom widget
      # @option options [String] :secret Your app secret for secure mode
      # @return [String] Intercom script tag
      #
      # @example Basic usage
      #   <%= intercom_script_tag {
      #     app_id: "your-app-id",
      #     user: {
      #       id: current_user.id,
      #       email: current_user.email,
      #       name: current_user.name,
      #       plan: current_user.plan.name # this is custom data
      #     }
      #   } %>
      #
      # @example Pass company information
      #   <%= intercom_script_tag {
      #     app_id: "your-app-id",
      #     user: {
      #       id: current_user.id,
      #       email: current_user.email,
      #       name: current_user.name,
      #       plan: current_user.plan.name # this is custom data
      #     },
      #     company: {
      #       id : current_user.company.id,
      #       name: current_user.company.name
      #     }
      #   } %>
      #
      # @example With widget activator for launching then widget when an element matching the css selector '#Intercom' is clicked.
      #   <%= intercom_script_tag {
      #     app_id: "your-app-id",
      #     user: {
      #       id: current_user.id,
      #       email: current_user.email,
      #       name: current_user.name,
      #     },
      #     widget: {
      #       activator: '#Intercom'
      #     }
      #   } %>
      def intercom_script_tag
        output = ''

        begin
          output << Intercom::Rails::Script.new(__intercom).output
        rescue Exception => e
          return unless defined?(:logger) # do nothing when logger is not present
          logger.fatal "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
        end

        output.html_safe
      end

      # @private
      def __intercom_javascript
        # TODO: check if intercom script tag already present
        return unless __intercom.enabled? # generally enabled?
        return unless response.content_type == 'text/html' # is a html request?
        return unless response.body =~ %r{</body>} # has a closing body tag?

        response.body = response.body.sub(%r{</body>}, intercom_script_tag + '\\0')
      end

      # @private
      def __intercom
        return @__intercom if defined?(@__intercom)

        if configuration = Intercom::Rails::Repository[self.class]
          @__intercom = Intercom::Rails::Configuration.new(self, &configuration)
        else
          @__intercom = nil
        end
      end

      # @private
      def __intercom?
        __intercom.present? and __intercom.enabled?
      end

    end
  end
end
