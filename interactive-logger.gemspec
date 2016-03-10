Gem::Specification.new do |s|
  s.name        = 'interactive-logger'
  s.version     = '0.1.1'
  s.licenses    = ['MIT']
  s.summary     = 'A colorful, interactive logger.'
  s.description = 'A colorful, interactive logger for tracking progress of an operation.'
  s.authors     = ['Kyle Smith <askreet@gmail.com>']
  s.email       = 'askreet@gmail.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/askreet/interactive-logger'

  s.add_dependency('colorize', '~> 0.7.7')
  s.add_dependency('ruby-duration', '~> 3.2', '>= 3.2.3')
end
