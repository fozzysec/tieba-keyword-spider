#!/usr/bin/env perl

open($fh, '<:encoding(utf-8)', "/etc/auto_generate_filter.conf");
while(! eof($fh)){
	chomp($file = readline($fh));
	chomp($keyword = readline($fh));
	system("cd /root/filter_tieba&&scrapy crawl tieba -s FILENAME=/tmp/$file.jl -a keywords='$keyword'");
	system("echo '$keyword' > /data/ayatv/tieba2/$file.html");
	system("/usr/bin/env perl /root/filter_tieba/generator.pl /tmp/$file.jl >> /data/ayatv/tieba2/$file.html");
}
