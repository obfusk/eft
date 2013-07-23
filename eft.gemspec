require File.expand_path('../lib/eft/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'eft'
  s.homepage    = 'https://github.com/obfusk/eft'
  s.summary     = 'ruby + whiptail'

  s.description = <<-END.gsub(/^ {4}/, '')
    ...
  END

  s.version     = Eft::VERSION
  s.date        = Eft::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.license     = 'GPLv2'

  s.files       = %w{ README.md eft.gemspec }\
                + Dir['lib/**/*.rb']

  s.add_runtime_dependency 'obfusk-util'

  # s.add_development_dependency  'rake'
  # s.add_development_dependency  'rspec'

  s.required_ruby_version = '>= 1.9.1'
end
