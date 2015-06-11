require 'newrelic_rpm'
require 'new_relic/agent/instrumentation/controller_instrumentation'

module PromiscuousNewRelicInstrumented
  extend ActiveSupport::Concern
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  module ClassMethods
    def newrelic_namespace(&block)
      if block_given?
        @newrelic_namespace = block
      else
        @newrelic_namespace
      end
    end

    def instrument(method_name)
      alias_method "orig_#{method_name}", method_name

      define_method method_name do |*args, &block|
        trace_params = {
          :name       => instance_eval(&self.class.newrelic_namespace),
          :class_name => 'Subscriber',
          :force      => true,
          :category   => "OtherTransaction/Promiscuous"
        }
        perform_action_with_newrelic_trace(trace_params) do
          __send__("orig_#{method_name}", *args, &block)
        end
      end
    end
  end
end
