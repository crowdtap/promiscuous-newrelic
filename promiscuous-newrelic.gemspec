# encoding: utf-8
$:.unshift File.expand_path("../lib", __FILE__)
$:.unshift File.expand_path("../../lib", __FILE__)

require 'promiscuous/new_relic/version'

Gem::Specification.new do |s|
  s.name        = "promiscuous-newrelic"
  s.version     = Promiscuous::NewRelic::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nicolas Viennot", "Kareem Kouddous"]
  s.email       = ["nicolas@viennot.biz", "kareem@doubleonemedia.com"]
  s.homepage    = "http://github.com/crowdtap/promiscuous-newrelic"
  s.summary     = "NewRelic Agent for Promiscuous"
  s.description = "NewRelic Agent for Promiscuous"

  s.add_dependency 'newrelic_rpm'
  s.add_dependency 'activesupport'
  s.add_dependency 'promiscuous', '>= 0.50.0'

  s.add_development_dependency 'rspec', '~> 3.2'
  s.add_development_dependency 'pry'

  s.files        = Dir["lib/**/*"] + ['README.md']
  s.require_path = 'lib'
  s.has_rdoc     = false
end
