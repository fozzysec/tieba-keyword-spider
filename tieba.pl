#!/usr/bin/env perl

open($fh, '<:encoding(utf-8)', "/etc/tieba.txt") or die "failed to open file";
while(! eof($fh)){
	chomp($file = readline($fh));
	chomp($keyword = readline($fh));
	system("cd /root/tieba&&scrapy crawl tieba -s FILENAME=/root/tieba/$file -a keywords='$keyword'");
	system("/usr/bin/env perl /root/tieba/generator.pl /root/tieba/$file > /tmp/$file.html");
}
close($fh);
system("/usr/bin/env perl /root/tieba/sendmail.pl");
