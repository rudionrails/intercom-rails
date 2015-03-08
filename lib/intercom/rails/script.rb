module Intercom
  module Rails
    class Script

      # @private
      #
      # usage
      #   SETTINGS % {settings: "{'hello': 'world'}"}
      SETTINGS = <<-EOS
<script id="IntercomSettingsScriptTag">
  window.intercomSettings = %{settings};
</script>
EOS
      # @private
      #
      # usage
      #   SOURCE % {source: 'https://my.source.com'}
      SOURCE = <<-EOS
<script>(function(){var w=window;var ic=w.Intercom;if(typeof ic==="function"){ic('reattach_activator');ic('update',intercomSettings);}else{var d=document;var i=function(){i.c(arguments)};i.q=[];i.c=function(args){i.q.push(args)};w.Intercom=i;function l(){var s=d.createElement('script');s.type='text/javascript';s.async=true;s.src='%{source}';var x=d.getElementsByTagName('script')[0];x.parentNode.insertBefore(s,x);}if(w.attachEvent){w.attachEvent('onload',l);}else{w.addEventListener('load',l,false);}};})()</script>
EOS

      def initialize( intercom )
        @intercom = intercom
      end

      def output
        o = ''
        o << SETTINGS % {settings: settings}
        o << SOURCE % {source: source}
        o
      end


      private

      def settings
        s = { app_id: @intercom.settings[:app_id] }

        s.merge!(user_settings) if @intercom.user.present?
        s.merge!(company: company_settings) if @intercom.company.present?

        ActiveSupport::JSON.encode(s).gsub('<', '\u003C')
      end

      def source
        @intercom.settings[:library_url] || "https://widget.intercom.io/widget/#{@intercom.settings[:app_id]}"
      end

      def user_settings
        user = @intercom.user.to_h
        user[:user_id] = user.delete(:id)

        if secret = @intercom.settings[:secret]
          data = (user[:id] || user[:user_id] || user[:email]).to_s
          user[:user_hash] = OpenSSL::HMAC.hexdigest("sha256", secret, data)
        end

        sanitize(user)
      end

      def company_settings
        company = @intercom.company.to_h
        sanitize(company)
      end

      def sanitize( object )
        case object
        when Time, DateTime then object.to_i
        when Hash then Hash[object.map { |k, v| [k, sanitize(v)] }]
        else object
        end
      end

    end
  end
end


