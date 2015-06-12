
DependencyDetection.defer do
  @name = :promiscuous

  depends_on do
    defined?(Promiscuous::CLI) and not NewRelic::Control.instance['disable_promiscuous']
  end

  executes do
    if defined?(Promiscuous::BlackHole)
      Promiscuous::Subscriber::UnitOfWork.class_eval do
        include PromiscuousNewRelicInstrumented

        instrument :process
        newrelic_namespace { "Normcore2/#{message.base_type}/#{message.operation}" }
      end
    else
      Promiscuous::Subscriber::UnitOfWork.class_eval do
        include PromiscuousNewRelicInstrumented

        instrument :execute_operation
        newrelic_namespace { "#{self.app}/#{operation.model.to_s}/#{operation.operation}" }
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
