#!/usr/bin/env perl

use Cwd qw(abs_path);
use File::Basename;

use open ':std', ':encoding(UTF-8)';

$maillist = 'maillist.conf';

$path = dirname(abs_path(__FILE__)).'/';
open(my $FH, '<:encoding(UTF-8)', $path.$maillist) or die "failed open file.";

while(<$FH>){
	chomp;
	my @array = split(/:/, $_);
	my $keyword = $array[0];
	my $file = $array[2];
	system("cd /root/tieba&&scrapy crawl tieba -s FILENAME=/root/tieba/$file -a keywords='$keyword'");
	system("/usr/bin/env perl /root/tieba/generator.pl /root/tieba/$file > /tmp/$file.html");
}
close($FH);
system("/usr/bin/env perl /root/tieba/sendmail.pl");
