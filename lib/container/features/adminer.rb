require_relative './base'

module Container::Features
	class Adminer < Base
		NETWORK = 'adminer'

		def present?
			return @container.env.include?('ADMINER_NAME')
		end

		def problems
			return [
				unless @container.networks.include?(NETWORK)
					'ADMINER_NAME set, but not on the adminer network'
				end,
			].compact
		end

		def name
			return @container.env['ADMINER_NAME']
		end

		fields :name
	end
end
