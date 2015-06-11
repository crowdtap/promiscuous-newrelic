require 'active_support'
require 'promiscuous-newrelic'

class InstrumentedKlass
  attr_accessor :method_calls

  def app
    'test_app'
  end

  def initialize
    self.method_calls = 0
    @namespace = 'SuperCoolModel'
  end

  def foo
    self.method_calls += 1
  end
end

InstrumentedKlass.class_eval do
  include PromiscuousNewRelicInstrumented
  instrument :foo
  newrelic_namespace { @namespace }
end

describe PromiscuousNewRelicInstrumented do
  subject { InstrumentedKlass.new }

  describe '.instrument' do
    it 'calls the original method' do
      subject.foo

      expect(subject.method_calls).to eq(1)
    end

    it 'calls perform_action_with_newrelic_trace with the right params' do
      expect(subject).to receive(:perform_action_with_newrelic_trace).with(
        :name => 'SuperCoolModel',
        :class_name => 'Subscriber',
        :force => true,
        :category => 'OtherTransaction/Promiscuous'
      )

      subject.foo
    end
  end
end
