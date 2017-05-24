require_relative './base'

module Container::Features
	class ProxySSL < Base
		def present?
			return
				@container.env.include?('LETSENCRYPT_HOST') || 
				@container.env.include?('LETSENCRYPT_EMAIL')
		end

		def problems
			return [
				unless @container.env.include?('LETSENCRYPT_HOST')
					'LETSENCRYPT_HOST missing'
				end,
				unless @container.env.include?('LETSENCRYPT_EMAIL')
					'LETSENCRYPT_EMAIL missing'
				end,
				if @container.env['LETSENCRYPT_HOST'] != @container.env['VIRTUAL_HOST']
					'LETSENCRYPT_HOST different from VIRTUAL_HOST'
				end,
			].compact
		end
	end
end
