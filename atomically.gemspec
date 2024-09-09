# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atomically/version'

Gem::Specification.new do |spec|
  spec.name          = 'atomically'
  spec.version       = Atomically::VERSION
  spec.authors       = ['khiav reoy']
  spec.email         = ['mrtmrt15xn@yahoo.com.tw']

  spec.summary       = 'An ActiveRecord extension for writing commonly useful atomic SQL statements to avoid race condition.'
  spec.description   = 'An ActiveRecord extension for writing commonly useful atomic SQL statements to avoid race condition.'
  spec.homepage      = 'https://github.com/khiav223577/atomically'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject{|f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}){|f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.metadata      = {
    'homepage_uri'      => 'https://github.com/khiav223577/atomically',
    'changelog_uri'     => 'https://github.com/khiav223577/atomically/blob/master/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/khiav223577/atomically',
    'documentation_uri' => 'https://www.rubydoc.info/gems/atomically',
    'bug_tracker_uri'   => 'https://github.com/khiav223577/atomically/issues',
  }

  spec.add_development_dependency 'bundler', '>= 1.17', '< 3.x'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mysql2', '>= 0.3'
  spec.add_development_dependency 'pg', '~> 0.18'
  spec.add_development_dependency 'pluck_all', '>= 2.0.3'
  spec.add_development_dependency 'timecop', '~> 0.9.1'
  spec.add_development_dependency 'rails_compatibility', '>= 0.0.8'

  spec.add_dependency 'activerecord', '>= 3'
  spec.add_dependency 'activerecord-import', '>= 0.27.0'
  spec.add_dependency 'rails_or', '>= 1.1.8'
  spec.add_dependency 'update_all_scope', '~> 0.1.0'
end
