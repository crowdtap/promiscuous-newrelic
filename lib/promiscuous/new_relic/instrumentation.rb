require 'new_relic/agent/instrumentation/controller_instrumentation'

DependencyDetection.defer do
  @name = :promiscuous

  depends_on do
    defined?(Promiscuous::Common::Worker) and not NewRelic::Control.instance['disable_promiscuous']
  end

  executes do
    Promiscuous::Common::Worker.class_eval do
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation

      alias_method :unit_of_work_without_rpm, :unit_of_work
      def unit_of_work(type, &block)
        # XXX All the publishers are using the same category
        # (Just because it's hard to make sense of what it really means
        # to split things up. Maybe we should not even report the publisher worker.
        worker_type = type == 'publisher' ? "Publishers" : "Subscribers"

        perform_action_with_newrelic_trace(:class_name => type,
                                           :category => "OtherTransaction/Promiscuous#{worker_type}") do
          unit_of_work_without_rpm(type, &block)
        end
      end
    end

    NewRelic::Agent.logger.debug 'Using Promiscuous Instrumentation'
  end
end
