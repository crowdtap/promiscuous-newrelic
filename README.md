# Promiscuous New Relic Agent

New Relic instrumentation for Promiscuous

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'promiscuous-newrelic'
```

`promiscuous-newrelic` uses the new relic gem's dependency detection, which has
hooks into rails and rack projects. If you're using this instrumentation in a
project without rails or rack, you must manually call `DependencyDetection.detect!` after
gems have been required.
