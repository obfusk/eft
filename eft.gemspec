require File.expand_path('../lib/eft/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'eft'
  s.homepage    = 'https://github.com/obfusk/eft'
  s.summary     = 'ruby + whiptail'

  s.description = <<-END.gsub(/^ {4}/, '')
    ruby + whiptail

    ...
  END

  s.version     = Eft::VERSION
  s.date        = Eft::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.licenses    = %w{ GPLv2 EPLv1 }

  s.files       = %w{ .yardopts README.md Rakefile } \
                + %w{ eft.gemspec example.rb } \
                + Dir['lib/**/*.rb']

  s.add_runtime_dependency 'obfusk-util'

  s.add_development_dependency 'rake'
# s.add_development_dependency 'rspec'

  s.required_ruby_version = '>= 1.9.1'
end
