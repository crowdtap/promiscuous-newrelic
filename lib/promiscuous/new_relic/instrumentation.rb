require 'new_relic/agent/instrumentation/controller_instrumentation'

DependencyDetection.defer do
  @name = :promiscuous

  depends_on do
    defined?(Promiscuous::Common::Worker) and not NewRelic::Control.instance['disable_promiscuous']
  end

  executes do
    Promiscuous::Common::Worker.module_eval do
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation

      alias_method :unit_of_work_without_rpm, :unit_of_work
      def unit_of_work(type, &block)
        # XXX All the publishers are using the same category
        # (Just because it's hard to make sense of what it really means
        # to split things up. Maybe we should not even report the publisher worker.
        worker_type = type == 'publisher' ? 'Publisher' : 'Subscriber'
        name        = type == 'publisher' ? 'all' : type

        # We are not using the subscriber class name, because of polymorphism
        # We only want the parent class basically
        perform_action_with_newrelic_trace(:name => name, :class_name => worker_type, :force => true,
                                           :category => "OtherTransaction/Promiscuous") do
          unit_of_work_without_rpm(type, &block)
        end
      end
    end

    Promiscuous::Worker.module_eval do
      class << self
        alias_method :replicate_without_rpm, :replicate
        alias_method :stop_without_rpm, :stop

        def replicate(options={})
          NewRelic::Agent.manual_start
          replicate_without_rpm(options)
        end

        def stop
          stop_without_rpm
          NewRelic::Agent.shutdown
        end
      end
    end

    NewRelic::Agent.logger.debug 'Using Promiscuous Instrumentation'
  end
end
