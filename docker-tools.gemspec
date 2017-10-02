Gem::Specification.new do |s|
	s.name        = 'docker-tools'
	s.version     = '0.1.0'
	s.date        = '2017-10-02'
	s.summary     = "Tools for docker"
	s.description = "Somewhat more advanced versions of some of docker's built-in commands"
	s.authors     = ["Michon van Dooren"]
	s.email       = 'michon1992@gmail.com'
	s.files       = Dir["{lib}/**/*.rb", "bin/*"]
	s.executable  = 'docker-tools'
	s.homepage    = 'https://github.com/MaienM/docker-tools'
	s.license     = 'MIT'

	# Extension methods
	s.add_dependency 'facets'
	s.add_dependency 'andand'
	# Command line stuff
	s.add_dependency 'commander'
	s.add_dependency 'colorize'
	s.add_dependency 'terminal-table'
	# Other?
	s.add_dependency 'chronic_duration'
	# Development
	s.add_development_dependency 'pry'
end

