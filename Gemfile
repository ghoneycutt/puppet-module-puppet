source ENV['GEM_SOURCE'] || 'https://rubygems.org'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

gem 'activesupport', '~> 4.0', :require => false if RUBY_VERSION < '2.2'
gem 'facter', '>= 2.0', :require => false
gem 'hiera', '~> 3.0', :require => false
gem 'metadata-json-lint', :require => false
gem 'puppet-lint', '~> 2.0', :require => false
gem 'puppet-lint-absolute_classname-check', :require => false
gem 'puppet-lint-alias-check', :require => false
gem 'puppet-lint-classes_and_types_beginning_with_digits-check', :require => false
gem 'puppet-lint-empty_string-check', :require => false
gem 'puppet-lint-file_ensure-check', :require => false
gem 'puppet-lint-file_source_rights-check', :require => false
gem 'puppet-lint-leading_zero-check', :require => false
gem 'puppet-lint-resource_reference_syntax', :require => false
gem 'puppet-lint-spaceship_operator_without_tag-check', :require => false
gem 'puppet-lint-trailing_comma-check', :require => false
gem 'puppet-lint-undef_in_function-check', :require => false
gem 'puppet-lint-unquoted_string-check', :require => false
gem 'puppet-lint-variable_contains_upcase', :require => false
gem 'puppet-lint-version_comparison-check', :require => false
gem 'puppetlabs_spec_helper', '>= 1.2.0', :require => false
gem 'rspec-puppet', :require => false
gem 'rspec-puppet-facts', :require => false
gem 'rubocop', :require => false

# Rack is a dependency of github_changelog_generator
gem 'github_changelog_generator', require: false
if RUBY_VERSION <= '2.2.2'
  gem 'rack', '~> 1.0', :require => false
else
  gem 'rack', :require => false
end
