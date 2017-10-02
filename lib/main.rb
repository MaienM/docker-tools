#!/usr/bin/env ruby

require 'facets'
require 'andand'
require 'commander'
require 'colorize'
require 'terminal-table'
require 'chronic_duration'
require_relative './ext'

class App
	include Commander::Methods

	module Commands
	end

	INDENT = 2

	class << self
		def command(name, &block)
			@commands ||= []
			@commands << {
				name: name,
				type: :command,
				block: block,
			}
		end

		def alias_command(name, *args)
			@commands ||= {}
			@commands << {
				name: name,
				type: :alias,
				args: args,
			}
		end

		def commands
			return @commands || {}
		end
	end

	def run
		program :name, 'docker-tools'
		program :version, '0.0.1'
		program :description, 'Docker tools'

		self.class.commands.each do |info|
			case info[:type]
				when :command
					command info[:name] do |*args|
						instance_exec(*args, &info[:block])
					end
				when :alias
					alias_command(info[:name], *info[:args])
				else
					throw "Unsupport command type #{info[:type]} for command #{info[:name]}"
			end
		end

		run!
	end
end

require_relative './ps'
require_relative './inspect'

App.new.run if $0 == __FILE__
