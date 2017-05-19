#!/usr/bin/env ruby

require 'json'
require 'bundler'
Bundler.require

require_relative './container'

if ARGV.empty?
	puts 'Cannot inspect nothing!'
	exit 1
elsif ARGV == %w(-)
	data = JSON.parse($stdin.read)
else
	data = JSON.parse(`sudo docker inspect #{ARGV.join(' ')}`)
end

data.each do |container_data|
	c = Container::Container.new(container_data)

	puts <<~ENDC
		Name: #{c.name}
		Project: #{c.project}
		Image:
		  Host: #{c.image.host}
		  Name: #{c.image.name}
		  Tag: #{c.image.tag}
		Status: TODO
		Health: #{c.problems? ? 'bad'.red : 'good'.green}
		#{c.features.to_h.map do |_, f|
		next <<~ENDF
			---
			Feature #{f.class.basename}
			Enabled: #{f.present? ? 'yes'.green : 'no'.red}
			#{if f.present?
			<<~ENDFE
				Health: #{f.problems? ? 'bad'.red : 'good'.green}
				#{if f.problems?
				<<~ENDFP
					Problems:
					  #{f.problems.join("\n  ")}
				ENDFP
				end}
			ENDFE
			end}
		ENDF
		end.map(&:rstrip).join("\n")}
	ENDC
end
