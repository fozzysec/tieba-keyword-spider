require 'json'
require 'active_support/core_ext/array/conversions'

begin
	file = File.open(ARGV[0], "r")
	file.each do |line|
		print JSON.parse(line)
		print "\n"
	end
rescue

ensure
	file.close if not file.nil?
end
