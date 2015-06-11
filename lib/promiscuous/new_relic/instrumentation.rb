require 'new_relic/agent/instrumentation/controller_instrumentation'

module PromiscuousNewRelicInstrumentedClass
  extend ActiveSupport::Concern
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  module ClassMethods
    def instrument(method_name)
      alias_method "orig_#{method_name}", method_name

      define_method method_name do |*args, &block|
        perform_action_with_newrelic_trace(:name => namespace_for_rpm(operation), :class_name => 'Subscriber', :force => true,
                                           :category => "OtherTransaction/Promiscuous") do
          __send__("orig_#{method_name}", *args, &block)
        end
      end
    end
  end


  included do
    private
    def namespace_for_rpm(operation)
      "#{self.app}/#{operation.model.to_s}/#{operation.operation}"
    end
  end
end

DependencyDetection.defer do
  @name = :promiscuous

  depends_on do
    defined?(Promiscuous::CLI) and not NewRelic::Control.instance['disable_promiscuous']
  end

  executes do
    Promiscuous::Subscriber::UnitOfWork.class_eval do
      include PromiscuousNewRelicInstrumentedClass

      instrument :execute_operation
    end

    Promiscuous::CLI.class_eval do
      alias_method :run_without_rpm, :run
      def run
        NewRelic::Agent.manual_start
        run_without_rpm
      ensure
        NewRelic::Agent.shutdown
      end
    end

    NewRelic::Agent.logger.debug 'Using Promiscuous Instrumentation'
  end
end
