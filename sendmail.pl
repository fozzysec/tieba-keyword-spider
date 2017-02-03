#!/usr/bin/env perl
#
use Cwd qw(abs_path);
use File::Basename;

$maillist = 'maillist.conf';

sub sendmail{
	my @conf = @_;
	my $cmd = "mutt -e 'set content_type=text/html' -s '$conf[0]' $conf[1] < /tmp/$conf[2].html";
	system($cmd);	
}

$path = dirname(abs_path(__FILE__)).'/';
open(my $FH, '<:encoding(UTF-8)', $path.$maillist);

while(! eof($FH)){
	my $line = readline($FH);
	chomp($line);
	my @array = split(/:/, $line);
	sendmail(@array);
}
close($FH);
