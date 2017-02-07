#!/usr/bin/env perl

use Cwd qw(abs_path);
use File::Basename;

use open ':std', ':encoding(UTF-8)';


$path = dirname(abs_path(__FILE__)).'/';
require $path."config.pl";
my $maillist = $g_maillist;
my $generator = $g_generator;
my $sendmail = $g_sendmail;
my $tmpdir = $g_tmpdir;

open(my $FH, '<:encoding(UTF-8)', $path.$maillist) or die "failed open file.";

while(<$FH>){
	chomp;
	my @array = split(/:/, $_);
	my $keyword = $array[0];
	my $file = $array[2];
	system("cd $path&&scrapy crawl tieba -s FILENAME=$tmpdir$file -a keywords='$keyword'");
	system("/usr/bin/env perl $path$generator $tmpdir$file > $tmpdir$file.html");
}

close($FH);
system("/usr/bin/env perl ".$path.$sendmail);
