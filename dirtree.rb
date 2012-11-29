#!/usr/bin/env ruby
require 'optparse'
require 'date'
require 'fileutils'

#######
# Default options
#
options = {}
guide_symbol = ':'
goes_deeper_symbol = '/...'

optparse = OptionParser.new do |opts|
	opts.banner = "Usage dirtree [options] [path]" +
		"\noutputs representation of Folder structure from directory (default ./)"
	options[:start_directory] = options[:relative_path] = './'
	options[:goes_deeper_symbol] = goes_deeper_symbol
	options[:depth] = nil
	opts.on('-d', '--depth DEPTH', Integer, 'How deep to go into a directory. Unlimited by default.') do |d|
		options[:depth] = d
	end
	opts.on('-D', '--date [DATE[..RANGE]]', "A date range to limit files in output. Forces --full\neg. yyyy-dd-mm..yesterday") do |dt|
		date_filter = dt.
			sub('today', Time.now.strftime('%Y-%m-%d')).
			sub('yesterday', (Time.now - 86400).strftime('%Y-%m-%d'))
		if !date_filter.match(/\.\./)
			date_filter = "#{date_filter}..#{date_filter}"
		elsif date_filter.match(/\.\.$/)
			date_filter  = "#{date_filter}#{Date.today.to_s}"
		elsif date_filter.match(/^\.\./)
			date_filter = "1970-01-01#{date_filter}"
		end
		d1, d2 = date_filter.split(/\.\./)
		options[:date_start] = Date.parse d1
		options[:date_end] = Date.parse d2
		options[:full]= true # force full/explicit mode when filtering by date
	end
	#
	# Switches
	options[:guide] = ' '
	opts.on('-g', '--guides', 'Display depth/level guides (vertical lines). Default off.') do
		options[:guide] = guide_symbol
	end
	opts.on('-o', '--only', 'Display only directories (omit files).') do
		options[:only] = true
	end
	opts.on('-f', '--full', 'Use full (relative) path instead of default graphical tree.') do
		options[:full] = true
	end
	#
	# Items to ignore (exclude from results)
	options[:ignore_list] = [
		/\.(svn|hg|git)$/
	]
	opts.on('-x', '--exclude REGEX', Regexp, 'a Ruby Regexp to exclude matching files from result-set.') do |r|
		options[:ignore_list] << r
	end
	#
	# Help
	opts.on('-h', '--help', 'Display this screen') do
		puts opts
		exit
	end
end

# remove options from ARGV, leave path if available
optparse.parse!

# look for an explicit starting directory
ARGV.each do |ar|
	if File.directory?(ar)
		options[:relative_path] = ar
		options[:start_directory] = File.expand_path(ar)
	end
end

class Dirtree
	def initialize(options)
		@options = options
		@max_depth = options[:depth]
	end

	def displaydir(path, depth = 0)
		Dir["#{path}/*"].each do |file|
			if File.directory?(file)
				goes_deeper_symbol = (@max_depth.nil? || (0 < @max_depth && depth < @max_depth)) \
					? '' \
					: @options[:goes_deeper_symbol]
				if @options[:ignore_list].all? { |rx| !file.match(rx) }
					if @options[:full].nil? || !@options[:full]
						print "#{@options[:guide]}  " * depth
						puts file, "/#{File.basename(file)}#{goes_deeper_symbol}"
					elsif @options[:only]
						puts file, file.to_s.sub('.//', './')
					end
					if @max_depth.nil? || (0 < @max_depth && depth < @max_depth) then
						displaydir("#{path}/#{File.basename(file)}", depth + 1)
					end
				end
			elsif !@options[:only ] && @options[:ignore_list].all? { |rx| !file.match(rx) }
				if @options[:full]
					puts file, file.to_s.sub(@options[:start_directory], @options[:relative_path]).sub('//', '/')
				else
					print "#{@options[:guide]}  " * depth
					puts file, "./#{File.basename(file)}"
				end
			end
		end
	end

	def puts( f, out )
		if @options[:date_start].nil? || @options[:date_end].nil?
			print out + "\n"
		else
			mdate, mtime = File.mtime(f).strftime('%Y-%m-%d %H:%M').split(/\s/)
			if @options[:date_start].to_s <= mdate && @options[:date_end].to_s >= mdate
				print "[#{mdate} #{mtime}]\t" + out  + "\n"
			end
		end
	end
end

# Finally perform our duties
Dirtree.new(options).displaydir(options[:start_directory])

