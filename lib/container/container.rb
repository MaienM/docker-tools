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
			state = raw['State']
			info = {
				running: state['Running'],
				created: DateTime.parse(raw['Created']),
				status: state['Status'],
			}
			if info[:running]
				info[:statusExtra] = {
					pid: state['Pid'],
				}
				info[:since] = DateTime.parse(state['StartedAt'])
			else
				info[:statusExtra] = {
					exitCode: state['ExitCode'],
					oom: state['OOMKilled'],
				}
				info[:since] = DateTime.parse(state['FinishedAt'])
			end
			info[:statusExtra][:error] = state['Error'] unless state['Error'].empty?

			info = OpenStruct.new(info)
			info.statusExtra = OpenStruct.new(info.statusExtra)

			return info
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

		def labels
			return raw['Config']['Labels']
		end

		def networks
			return raw['NetworkSettings']['Networks'].keys
		end

		def problems?
			return !problems.empty?
		end

		def problems
			return features.to_h.values.select(&:present?).map(&:problems).flatten.compact
		end

		memoize *%i(name status image env networks problems)
	end
end
