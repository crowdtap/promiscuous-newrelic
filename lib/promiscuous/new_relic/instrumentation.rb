require 'new_relic/agent/instrumentation/controller_instrumentation'

DependencyDetection.defer do
  @name = :promiscuous

  depends_on do
    defined?(Promiscuous::Common::Worker) and not NewRelic::Control.instance['disable_promiscuous']
  end

  executes do
    Promiscuous::Subscriber::Worker::Message.class_eval do
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation

      alias_method :unit_of_work_without_rpm, :unit_of_work
      def unit_of_work(type, &block)
        # We are not using the subscriber class name, because of polymorphism
        # We only want the parent class basically
        perform_action_with_newrelic_trace(:name => type, :class_name => 'Subscriber', :force => true,
                                           :category => "OtherTransaction/Promiscuous") do
          unit_of_work_without_rpm(type, &block)
        end
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
