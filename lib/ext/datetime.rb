class DateTime
	def epoch
		return to_time.to_i
	end

	# Determine how long after the current datetime the other datetime lies
	def seconds_until(other)
		return other.epoch - epoch
	end

	def format_time_since(options={})
		return ChronicDuration.output(seconds_until(DateTime.now), options)
	end
end
