require_relative './base'

module Container::Features
	class Proxy < Base
		NETWORK = 'proxy'

		def present?
			return @container.env.include?('VIRTUAL_HOST')
		end

		def problems
			return [
				unless @container.networks.include?(NETWORK)
					'VIRTUAL_HOST set, but not on the proxy network'
				end,
			].compact
		end

		def hosts
			return (@container.env['VIRTUAL_HOST'] || '').split(',')
		end
	end
end
