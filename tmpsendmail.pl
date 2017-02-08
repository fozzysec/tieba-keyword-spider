#!/usr/bin/env perl
#
use utf8;
use Cwd qw(abs_path);
use File::Basename;
use Data::Dumper;
use feature qw(say);

use open ':std', ':encoding(UTF-8)';

$path = dirname(abs_path(__FILE__)).'/';

require $path."config.pl";

my $maillist = $g_maillist;
my $tmpdir = $g_tmpdir;

my $subject = "来自瑟瑟发抖的剑三交易吧楼主的邮件";

sub sendmail{
	my @conf = @_;
	my $mails = $conf[1];
	foreach(split(/\|/, $mails)){
		if($_ =~ m/.*\@qq\.com/){
			my $cmd = "mutt -e 'set content_type=text/html' -s '$subject' $_ < $tmpdir"."notification.html";
			system($cmd);	
		}
	}
}

open(my $FH, '<:encoding(UTF-8)', $path.$maillist) or die "failed open file";

while(<$FH>){
	chomp;
	my @array = split(/:/, $_);
	if($array[1] =~ m/.*\@qq\.com.*/){
		sendmail(@array);
		say join(':', @array);
	}
}
close($FH);
