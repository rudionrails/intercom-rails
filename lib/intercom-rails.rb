require 'intercom/rails/repository'
require 'intercom/rails/configuration'
require 'intercom/rails/proxy'
require 'intercom/rails/script'
require 'intercom/rails/helpers'

module Intercom
  module Rails

    # Intercom::Rails.configure ApplicationController do
    #   set :app_id, '123abc'
    #   set :secret, '123abc-456def'
    #
    #   user.instance { |controller| controllercontext.current_user }
    #   user.reject { |user| user.deleted? }
    #   user.attributes do |user|
    #     {
    #       id: user.uuid,
    #       name: user.name,
    #       email: user.email
    #     }
    #   end
    #
    #   company.instance { |controller| controller.current_user.company }
    #   company.reject { |company| company.deleted? }
    #   company.attributes do |company|
    #     {
    #       id: company.uuid,
    #       name: company.name,
    #       email: company.email
    #     }
    #   end
    # end
    def self.configure( klass, &block )
      Intercom::Rails::Repository[klass] = block
      klass.send :include, Intercom::Rails::Helpers
    end

  end
end

