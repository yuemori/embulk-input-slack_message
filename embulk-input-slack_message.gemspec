
Gem::Specification.new do |spec|
  spec.name          = "embulk-input-slack_message"
  spec.version       = "0.1.0"
  spec.authors       = ["YOUR_NAME"]
  spec.summary       = "Slack Message input plugin for Embulk"
  spec.description   = "Loads records from Slack Message."
  spec.email         = ["YOUR_NAME"]
  spec.licenses      = ["MIT"]
  # TODO set this: spec.homepage      = "https://github.com/YOUR_NAME/embulk-input-slack_message"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'slack-api', ['~> 1.2.1']
  spec.add_development_dependency 'embulk', ['>= 0.8.3']
  spec.add_development_dependency 'bundler', ['>= 1.10.6']
  spec.add_development_dependency 'rake', ['>= 10.0']
end
