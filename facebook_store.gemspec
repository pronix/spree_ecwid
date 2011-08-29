Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'facebook_store'
  s.version     = '0.50.0'
  s.summary     = 'Add gem summary here'
  s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Pronix LLC'
  s.email             = 'root@tradefast.ru'
  s.homepage          = 'http://tradefast.ru'
  #s.rubyforge_project = 'actionmailer'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 0.50.0')
end
