#!/usr/bin/env perl

open($fh, '<:encoding(utf-8)', "/etc/auto_generate.conf");
while(! eof($fh)){
	chomp($file = readline($fh));
	chomp($keyword = readline($fh));
	system("cd /root/tieba&&scrapy crawl tieba -s FILENAME=/tmp/$file.jl -a keywords='$keyword'");
	system("echo '$keyword' > /nfs/ayatv/tieba/$file.html");
	system("/usr/bin/env perl /root/tieba/generator.pl /tmp/$file.jl >> /nfs/ayatv/tieba/$file.html");
}
