#!/usr/bin/env ruby
#
require 'json'

begin
	file = File.open(ARGV[0], "r")
	results = `wc -l #{ARGV[0]}`.strip.split(' ')[0]
	puts "<html><head><meta charset=\"utf-8\" />\n<title>Table of items</title></head>"
	puts "#{results} results generated at #{File.ctime(ARGV[0]).to_s}<br>"
	puts "<table border='1'>"
	puts "<tr>"
	puts "<th>帖子</th>"
	puts "<th>作者</th>"
	puts "<th>贴吧</th>"
	puts "<th>预览</th>"
	puts "<th>日期</th>"
	puts "<th>地址</th>"
	puts "</tr>"
	file.each do |line|
		puts "<tr>"
		json = JSON.parse(line)
		print "<td>" + json['title'] + "</td>\n"
		print "<td>" + json['author'] + "</td>\n"
		print "<td>" + json['tieba'] + "</td>\n"
		print "<td>" + json['preview'] + "</td>\n"
		print "<td>" + json['date'] + "</td>\n"
		print "<td><a href=\"" + json['url'] + "\">link</a></td>\n"
		puts "</tr>"
	end
	puts "</table></html>"
	file.close if not file.nil?
end
