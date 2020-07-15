# frozen_string_literal: true

trap('INT') do
	perror('You killed me :(')
end

# Standard libs
require 'optparse'
require 'ostruct'
require 'uri'
require 'net/http'

# Custom libs
require 'puf/version'
require 'puf/scanner'
require 'puf/prettyp'

# String class with color methods
String.class_eval do
	include Poison::Prettyp::Colors
end

# Printer methods
include Poison::Prettyp::Printer

# Enumerable module with parallel each
Enumerable.module_eval do
	def _peach_run(pool)
		div = (count / pool).to_i
		div = 10 unless div.positive?

		threads = []
		each_slice(div).with_index do |slice, idx|
			threads << Thread.new(slice) do |thread|
				yield thread, idx
			end
		end

		threads.each(&:join)
	end

	def peach(pool)
		_peach_run(pool) do |thread, idx|
			thread.each { |elt| yield elt, idx }
		end
	end	
end