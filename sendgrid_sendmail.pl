#!/usr/bin/env perl
#
use Cwd qw(abs_path);
use File::Basename;

use open ':std', ':encoding(UTF-8)';

$path = dirname(abs_path(__FILE__)).'/';

require $path."config.pl";

my $maillist = $g_maillist;
my $tmpdir = $g_tmpdir;

sub sendmail{
	my @conf = @_;
	my $mails = $conf[1];
	foreach(split(/\|/, $mails)){
		my $cmd = "mutt -e 'set content_type=text/html' -s '$conf[0]' $_ < $tmpdir$conf[2].html";
		system($cmd);	
	}
}

open(my $FH, '<:encoding(UTF-8)', $path.$maillist) or die "failed open file";

while(<$FH>){
	chomp;
	next if /^(\s*(#.*)?)?$/;
	my @array = split(/:/, $_);
	sendmail(@array);
}
close($FH);
