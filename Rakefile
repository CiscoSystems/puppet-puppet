require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'rspec-system/rake_task'

PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send("disable_arrow_alignment")
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_double_quoted_strings')
PuppetLint.configuration.send("disable_only_variable_string")
PuppetLint.configuration.send('disable_variables_not_enclosed')

##We need this for travis
PuppetLint.configuration.send('disable_autoloader_layout')

PuppetLint.configuration.ignore_paths = ["vendor/**/*.pp"]


desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
]
