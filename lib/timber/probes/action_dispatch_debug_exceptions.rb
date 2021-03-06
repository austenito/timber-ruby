module Timber
  module Probes
    # Reponsible for automatically tracking exception events in Rails applications. While
    # still preserving the default log style.
    class ActionDispatchDebugExceptions < Probe
      # For Rails >= 3.1
      # @private
      module DebugExceptionsInstanceMethods
        def self.included(klass)
          klass.class_eval do
            private
              def log_error(request, wrapper)
                logger = logger(request)
                return unless logger

                exception = wrapper.exception

                trace = wrapper.application_trace
                trace = wrapper.framework_trace if trace.empty?

                event = Events::Exception.new(
                  name: exception.class.name,
                  exception_message: exception.message,
                  backtrace: trace
                )

                logger.fatal event
              end
          end
        end
      end

      # For Rails < 3.1
      # @private
      module ShowExceptionsInstanceMethods #:nodoc:
        def self.included(klass)
          klass.class_eval do
            private
              # We have to monkey patch because ruby < 2.0 does not support prepend.
              alias_method :_timber_old_log_error, :log_error

              def log_error(exception)
                return unless logger

                event = Events::Exception.new(
                  name: exception.class.name,
                  exception_message: exception.message,
                  backtrace: application_trace(exception)
                )

                logger.fatal event
              end
          end
        end
      end

      def initialize
        begin
          # Rails >= 3.1
          require "action_dispatch/middleware/debug_exceptions"
        rescue LoadError
          # Rails < 3.1
          require "action_dispatch/middleware/show_exceptions"
        end
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        if defined?(::ActionDispatch::DebugExceptions)
          return true if ::ActionDispatch::DebugExceptions.include?(DebugExceptionsInstanceMethods)
          ::ActionDispatch::DebugExceptions.send(:include, DebugExceptionsInstanceMethods)
        else
          return true if ::ActionDispatch::ShowExceptions.include?(ShowExceptionsInstanceMethods)
          ::ActionDispatch::ShowExceptions.send(:include, ShowExceptionsInstanceMethods)
        end
      end
    end
  end
end