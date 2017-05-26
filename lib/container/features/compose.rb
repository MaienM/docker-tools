require_relative './base'

module Container::Features
	class Compose < Base
		def present?
			return @container.labels.include?('com.docker.compose.project')
		end

		def project
			return @container.labels['com.docker.compose.project']
		end

		def service
			return @container.labels['com.docker.compose.service']
		end

		fields :project, :service
	end
end
