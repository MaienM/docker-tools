require 'facets/memoizable'
require 'facets/ostruct'

REGEX_IMAGE = /^((?<host>.*:\/\/.*?)\/)?(?<name>[^\/]*(\/[^\/:]*)?)(:(?<tag>.*))?$/

module Container
	class Container
		include ::Memoizable

		def initialize(raw)
			@raw = raw

			# Initialize all features
			@features = Features::Base.subclasses.map do |fc|
				next [fc.basename.underscore, fc.new(self)]
			end.to_h.to_ostruct
		end

		def raw
			return @raw
		end

		def features
			return @features
		end

		def name
			return raw['Name'][1..-1]
		end

		def status
			return raw['State']['Status']
		end

		def image
			image = REGEX_IMAGE.match(raw['Config']['Image']).named_captures
			image = OpenStruct.new(image)
			image.tag = nil if image.tag == 'latest'
			return image
		end

		def env
			return raw['Config']['Env'].map { |e| e.split('=', 2) }.to_h
		end

		def networks
			return raw['NetworkSettings']['Networks'].keys
		end

		def project
			return raw['Config']['Labels']['com.docker.compose.project']
		end

		def problems?
			return !problems.empty?
		end

		def problems
			return features.to_h.values.select(&:present?).map(&:problems).flatten.compact
		end

		memoize *%i(name status image env networks project problems)
	end
end
