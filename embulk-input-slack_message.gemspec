
Gem::Specification.new do |spec|
  spec.name          = "embulk-input-slack_message"
  spec.version       = "0.1.0"
  spec.authors       = ["yuemori"]
  spec.summary       = "Slack Message input plugin for Embulk"
  spec.description   = "Loads records from Slack Message."
  spec.email         = ["yuemori@aiming-inc.com"]
  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/yuemori/embulk-input-slack_message"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rest-client'
  spec.add_dependency 'activesupport'
  spec.add_development_dependency 'embulk', ['>= 0.8.3']
  spec.add_development_dependency 'bundler', ['>= 1.10.6']
  spec.add_development_dependency 'rake', ['>= 10.0']
  spec.add_development_dependency 'pry'
end
