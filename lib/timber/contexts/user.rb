module Timber
  module Contexts
    # The user context tracks the currently authenticated user.
    #
    # You will want to add this context at the time log the user in, typically
    # during the authentication flow.
    #
    # Note: Timber will attempt to automatically add this if you add a #current_user
    # method to your controllers. Most authentication solutions do this for you automatically.
    #
    # @example Basic example
    #   user_context = Timber::Contexts::User.new(id: "abc1234", name: "Ben Johnson")
    #   Timber::CurrentContext.with(user_context) do
    #     # Logging will automatically include this context
    #     logger.info("This is a log message")
    #   end
    #
    # @example Rails example
    #   class ApplicationController < ActionController::Base
    #     around_filter :capture_user_context
    #     private
    #       def capture_user_context
    #         if current_user
    #           user_context = Timber::Contexts::User.new(id: current_user.id,
    #             name: current_user.name, email: current_user.email)
    #           Timber::CurrentContext.with(user_context) { yield }
    #         else
    #           yield
    #         end
    #       end
    #   end
    class User < Context
      @keyspace = :user

      attr_reader :id, :name, :email

      def initialize(attributes)
        @id = attributes[:id]
        @name = attributes[:name]
        @email = attributes[:email]
      end

      def as_json(_options = {})
        {id: Timber::Util::Object.try(id, :to_s), name: name, email: email}
      end
    end
  end
end