#!/usr/bin/env ruby
require 'date'
require 'fileutils'

#######
# Ruby
#
if ARGV.any? { |a| a.match /-h|--help|help/i }
	puts %Q{
	outputs Folder structure from directory (default ./)
	ignores versioning directories, logs, zip files

	OPTIONS:
	only  Display only directories (syn. tree)
	full  use full (relative) path instead of default
	      graphical representation (syn. explicit)
	help  Display this help message
	-img  Ignore image files:
	      graphics, docs, movies, audio
	-bin  Ignore executables
	-x    a Regexp to exclude matching files from result-set (syn. ignore)
	date  Filter by (modified) date, requires param date or range
	      shows only files that match date (or range)
		  ignores timestamp (hours, minutes, seconds)
		  eg. dirtree.rb date 2010-06-01..2010-06-30
		      dirtree date yesterday..
	-g    Display depth/level guides (vertical lines). Default off
	-d    Depth or how deep to go in directory structure
	      unlimited by default (if omitted)
		  -d 0 -> only current/top level
		  -d 2 -> current plus two levels down
	}
	exit
end

$start_directory = $relative_path = './'
$onlytree = ARGV.any? { |a| a.match /tree|only/i }
$explicit = ARGV.any? { |a| a.match /explicit|full/i }
$guide = ARGV.include?('-g') ? ':' : ' '
$max_depth = ARGV.include?('-d') ? ARGV[ ARGV.index('-d') + 1 ].to_i : nil
$ignore = [
	/\.(svn|hg|git|log|zip|\w+-bk\d+)$/
]
if ARGV.include?('-img') || ARGV.include?('-images')
	$ignore << /\.(gif|png|jpg|bmp|tif|doc|xls|ppt|pdf|swf|flv|fla|mpg|mp3|mp4|wmv|mov|rm)$/i
end
if ARGV.include?('-exe') || ARGV.include?('-bin') || ARGV.include?('-binary')
	$ignore << /\.(exe|com|bin|app|run|bat|jar|cab|so)$/i
end
if ARGV.include?('ignore')
	$ignore << Regexp.new( ARGV[ ARGV.index('ignore') + 1 ] )
end
if ARGV.include?('-x') # eXclude next param from search as a Regexp
	$ignore << Regexp.new( ARGV[ ARGV.index('-x') + 1 ] )
end
if ARGV.include?('date')
	date_filter = ARGV[ ARGV.index('date') + 1 ].
		sub('today', Time.now.strftime('%Y-%m-%d')).
		sub('yesterday', (Time.now - 86400).strftime('%Y-%m-%d')).
		sub('hour', (Time.now - 3600).strftime('%Y-%m-%d %H:%M:%S'))
	if !date_filter.match(/\.\./)
		date_filter = "#{date_filter}..#{date_filter}"
	elsif date_filter.match(/\.\.$/)
		date_filter  = "#{date_filter}#{Date.today.to_s}"
	elsif date_filter.match(/^\.\./)
		date_filter = "1970-01-01#{date_filter}"
	end
	d1, d2 = date_filter.split(/\.\./)
	$date_start = Date.parse d1
	$date_end   = Date.parse d2
	$explicit = true # force full/explicit mode when filtering by date
end
# look for an explicit starting directory
ARGV.each do |ar|
	if File.directory?(ar)
		$relative_path = ar
		$start_directory = File.expand_path($relative_path)
	end
end

def displaydir(path,depth)
	Dir["#{path}/*"].each do |file|
		if File.directory?(file)
			if $ignore.all? { |rx| !file.match(rx) }
				if !$explicit
					print "#{$guide}  "*depth
					myputs file, "/#{File.basename(file)}/..."
				elsif $onlytree
					myputs file, file.to_s.sub('.//', './')
				end
				if $max_depth.nil? || (0 < $max_depth && depth < $max_depth) then
					displaydir("#{path}/#{File.basename(file)}",depth+1)
				end
			end
		elsif !$onlytree && $ignore.all? { |rx| !file.match(rx) }
			if $explicit
				myputs file, file.to_s.sub($start_directory, $relative_path).sub('//', '/')
			else
				print "#{$guide}  "*depth
				myputs file, "./#{File.basename(file)}"
			end
		end
	end
end

def myputs( f, out )
	if $date_start.nil? || $date_end.nil?
		puts out
	elsif $date_start.to_s <= File.mtime(f).strftime('%Y-%m-%d') &&
		$date_end.to_s >= File.mtime(f).strftime('%Y-%m-%d')
		puts "[#{File.mtime(f).strftime('%Y-%m-%d %H:%M')}]\t" + out 
	end
end

displaydir($start_directory, 0)
