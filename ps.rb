#!/usr/bin/env ruby

require 'json'
require 'bundler'
Bundler.require
Bundler.require(:development)

require_relative './container'

if ARGV.empty?
	data = JSON.parse(`sudo docker ps -q | xargs sudo docker inspect`)
elsif ARGV == %w(-)
	data = JSON.parse($stdin.read)
else
	data = JSON.parse(`sudo docker inspect #{ARGV.join(' ')}`)
end

headers = %w(NAMES PROJECT IMAGE STATUS OTHER).map(&:blue)
rows = data.map do |container_data|
	c = Container::Container.new(container_data)
	next [
		c.name,
		c.project,
		[
			c.image.host && "#{c.image.host.bold.green}:",
			c.image.name,
			c.image.tag && ":#{c.image.tag.green}",
		].join,
		'',
		[
			if c.problems?
				"has problems".red
			end,
			if c.features.proxy.present?
				[
					c.features.proxy.problems? ? 'proxy'.red : 'proxy',
					if c.features.proxy_ssl.present?
						c.features.proxy_ssl.problems? ? '+'.red : '+'.green
					end,
					': ',
					c.features.proxy.hosts.join(', ').bold.green,
				].join
			end,
			if c.features.adminer.present?
				[
					c.features.adminer.problems? ? 'adminer'.red : 'adminer',
					': ',
					c.features.adminer.name.bold.green,
				].join
			end,
		].compact.join(', '),
	]
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
