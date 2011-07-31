#!/usr/bin/env ruby
require 'date'

#######
# Ruby
#
if ARGV.any? { |a| a.match /-h|--help|help/i }
	puts %Q{
	outputs Folder structure from current directory
	ignores versioning directories, logs, zip files

	OPTIONS:
	only  Display only directories (syn. tree)
	full  use full (relative) path instead of default
	      graphical representation (syn. explicit)
	help  Display this help message
	-img  Ignore image files:
	      graphics, docs, movies, audio
	-bin  Ignore executables
	ignore a Regexp to exclude matching files from result-set
	date  Filter by (modified) date, requires param date or range
	      shows only files that match date (or range)
		  ignores timestamp (hours, minutes, seconds)
		  eg. dirtree.rb date 2010-06-01..2010-06-30
	-g    Display depth/level guides (vertical lines). Default off
	}
	exit
end

$onlytree = ARGV.any? { |a| a.match /tree|only/i }
$explicit = ARGV.any? { |a| a.match /explicit|full/i }
$ignore = [
	/\.(svn|hg|git|log|zip|\w+-bk\d+)$/
]
$guide = ' '
if ARGV.include?('-img') || ARGV.include?('-images')
	$ignore << /\.(gif|png|jpg|bmp|tif|doc|xls|ppt|pdf|swf|flv|fla|mpg|mp3|mp4|wmv|mov|rm)$/i
end
if ARGV.include?('-exe') || ARGV.include?('-bin') || ARGV.include?('-binary')
	$ignore << /\.(exe|com|bin|app|run|bat|jar|cab|so)$/i
end
if ARGV.include?('ignore')
	$ignore << Regexp.new( ARGV[ ARGV.index('ignore') + 1 ] )
end
if ARGV.include?('-g')
	$guide = ':'
end
if ARGV.include?('date')
	date_filter = ARGV[ ARGV.index('date') + 1 ]
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

def displaydir(path,depth)
	Dir["#{path}/*"].each do |file|
		if File.directory?(file)
			if $ignore.all? { |rx| !file.match(rx) }
				if !$explicit
					print "#{$guide}  "*depth
					myputs file, "/#{File.basename(file)}/"
				elsif $onlytree
					myputs file, file.to_s.sub('.//', './')
				end
				displaydir("#{path}/#{File.basename(file)}",depth+1)
			end
		elsif !$onlytree && $ignore.all? { |rx| !file.match(rx) }
			if $explicit
				myputs file, file.to_s.sub('.//', './')
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

displaydir('./', 0)
