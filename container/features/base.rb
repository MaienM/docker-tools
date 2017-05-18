module Container::Features
	class Base
		def initialize(container)
			@container = container
		end

		# Should return a boolean indicating whether the feature is (partially) present
		def present?
			raise 'not implemented'
		end

		# Should return a list of problems with the feature, or an empty list if everything is fine
		def problems
			raise 'not implemented'
		end

		def problems?
			return !problems.empty?
		end
	end
end
