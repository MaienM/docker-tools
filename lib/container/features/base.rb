module Container::Features
	class Base
		def initialize(container)
			@container = container
		end

		# Should return a boolean indicating whether the feature is (partially)
		# present
		def present?
			raise 'not implemented'
		end

		# Should return a list of problems with the feature, an empty list if
		# everything is fine, or nil if the feature cannot have (detectable)
		# problems
		def problems
			return nil
		end

		def problems?
			p = problems
			return !p.nil? && !p.empty?
		end

		def supports_problems?
			return !problems.nil?
		end

		# Keep track of extra fields/properties of a feature
		def self.fields(*fields)
			@fields ||= []
			if fields.empty?
				return @fields
			else
				@fields += fields
			end
		end
	end
end
