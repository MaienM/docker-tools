require 'json'
require_relative './container'

class App
	command :inspect do |c|
		c.syntax = 'docker-tools inspect [options]'
		c.summary = 'A more friendly version of docker inspect'
		c.description = <<~END.rstrip
			Shows just the information that is (usually) relevant, in a clear,
			color coded way.

			Also has detection for common integrations with other containers and
			problems with these integrations.
		END
		c.example 'inspect container', 'docker-tools inspect container'
		c.action do |args, options|
			command_inspect(args, options)
		end
	end

	module Commands::Inspect
		def self.container(c)
			return <<~END.rstrip
				Name: #{c.name}
				Status:
				#{status(c.status).rstrip.indent(INDENT)}
				Image:
				#{image(c.image).rstrip.indent(INDENT)}
				Networks: #{c.networks.join(', ')}
				Health: #{c.problems? ? 'poor'.red : 'good'.green}
				#{c.features.to_h.values.map(&method(:feature)).compact.join("\n").rstrip}
			END
		end

		def self.status(s)
			return <<~END.rstrip
				Status: #{s.status} (#{s.statusExtra.to_h.map do |k, v|
					next v == !!v ? (v && k) : "#{k}: #{v}"
				end.compact.join(', ')})
				Since: #{s.since.format_time_since} (#{s.since})
				Created: #{s.created.format_time_since} (#{s.created})
			END
		end

		def self.image(i)
			return <<~END.rstrip
				Host: #{i.host}
				Name: #{i.name}
				Tag: #{i.tag}
			END
		end

		def self.feature(f)
			return unless f.present?
			return <<~END.rstrip
				#{f.class.basename}:
				#{_feature_present(f).andand.indent(INDENT)}
			END
		end

		def self._feature_present(f)
			return unless f.present?
			return [
				_feature_health(f),
				f.class.fields.map { |ff| "#{ff.to_s.titlecase}: #{f.send(ff)}" }.join("\n").rstrip,
			].compact.join("\n").rstrip
		end

		def self._feature_health(f)
			return unless f.supports_problems?
			return <<~END.rstrip
				Health: #{f.problems? ? 'poor'.red : 'good'.green}
				#{_feature_problems(f)}
			END
		end

		def self._feature_problems(f)
			return unless f.problems?
			return <<~END.rstrip
				Problems:
				#{f.problems.compact.join("\n").rstrip.indent(INDENT)}
			END
		end
	end

	def command_inspect(args, options)
		if args.empty?
			puts 'Cannot inspect nothing!'
			exit 1
		elsif args == %w(-)
			data = JSON.parse($stdin.read)
		else
			data = JSON.parse(`sudo docker inspect --type container #{args.join(' ')}`)
		end

		data.each do |container_data|
			c = ::Container::Container.new(container_data)
			puts Commands::Inspect.container(c)
		end
	end
end
