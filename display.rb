require 'json'

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
