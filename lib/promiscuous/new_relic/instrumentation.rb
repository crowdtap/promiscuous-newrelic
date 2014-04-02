require 'new_relic/agent/instrumentation/controller_instrumentation'

DependencyDetection.defer do
  @name = :promiscuous

  depends_on do
    defined?(Promiscuous::CLI) and not NewRelic::Control.instance['disable_promiscuous']
  end

  executes do
    Promiscuous::Subscriber::UnitOfWork.class_eval do
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation

      alias_method :execute_operation_without_rpm, :execute_operation
      def execute_operation(operation)
        # We are not using the subscriber class name, because of polymorphism
        # We only want the parent class basically
        perform_action_with_newrelic_trace(:name => namespace_for_rpm(operation), :class_name => 'Subscriber', :force => true,
                                           :category => "OtherTransaction/Promiscuous") do

          execute_operation_without_rpm(operation)
        end
      end

      private

      def namespace_for_rpm(operation)
        "#{self.app}/#{operation.model.to_s}/#{operation.operation}"
      end
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
