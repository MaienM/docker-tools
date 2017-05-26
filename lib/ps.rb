require 'json'
require_relative './container'

class App
	command :ps do |c|
		c.syntax = 'docker-tools ps [options]'
		c.summary = 'A more friendly version of docker ps'
		c.description = <<~END.rstrip
			Shows just the information that is (usually) relevant, in a clear,
			color coded way.

			Also has detection for common integrations with other containers and
			problems with these integrations.
		END
		c.example 'list containers', 'docker-tools ps'
		c.action do |args, options|
			command_ps(args, options)
		end
	end

	module Commands::Ps
		def self.container(c)
			return [
				c.name,
				c.features.compose.project,
				image(c.image),
				c.status,
				other(c),
			]
		end

		def self.image(i)
			return [
				i.host && "#{i.host.bold.green}:",
				i.name,
				i.tag && ":#{i.tag.green}",
			].join
		end

		def self.other(c)
			return [problems(c), feature_proxy(c), feature_adminer(c)].compact.join(', ')
		end

		def self.problems(c)
			return 'has problems'.red if c.problems?
		end

		def self.feature_proxy(c)
			return unless c.features.proxy.present?
			return [
					c.features.proxy.problems? ? 'proxy'.red : 'proxy',
					if c.features.proxy_ssl.present?
						c.features.proxy_ssl.problems? ? '+'.red : '+'.green
					end,
					': ',
					c.features.proxy.hosts.join(', ').bold.green,
			].join
		end

		def self.feature_adminer(c)
			return unless c.features.adminer.present?
			return [
				c.features.adminer.problems? ? 'adminer'.red : 'adminer',
				': ',
				c.features.adminer.name.bold.green,
			].join
		end
	end

	def command_ps(args, options)
		if args.empty?
			data = JSON.parse(`sudo docker ps -q | xargs sudo docker inspect`)
		elsif args == %w(-)
			data = JSON.parse($stdin.read)
		else
			data = JSON.parse(`sudo docker inspect #{args.join(' ')}`)
		end

		headers = %w(NAMES PROJECT IMAGE STATUS OTHER).map(&:blue)
		rows = data.map do |container_data|
			c = ::Container::Container.new(container_data)
			next Commands::Ps::container(c)
		end

		table = Terminal::Table.new do |t|
			t.rows = [headers] + rows
			t.style = {
				border_top: false,
				border_bottom: false,
				border_y: '',
				padding_left: 0,
				padding_right: 2,
			}
		end
		puts table
	end
end
