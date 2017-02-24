#!/usr/bin/env perl

use utf8;
use Cwd qw(abs_path);
use File::Basename;
use feature qw(say);
use Time::HiRes qw(usleep);

use open ':std', ':encoding(UTF-8)';


$path = dirname(abs_path(__FILE__)).'/';

require $path."config.pl";

my $maillist = $g_maillist;
my $generator = $g_generator;
my $sendmail = $g_sendmail;
my $tmpdir = $g_tmpdir;
my $workers = $g_workers;

open(my $FH, '<:encoding(UTF-8)', $path.$maillist) or die "failed open file.";

my $counter = 0;
my @pid = ($workers);

#set to 1 to ensure parent process always do clean up steps,
#in child process, fork() is always called and $curr_pid is always set to 0
my $curr_pid = 1;

while(<$FH>){
	chomp;
	next if /^(\s*(#.*)?)?$/;
	my @array = split(/:/, $_);
	my $keyword = $array[0];
	my $file = $array[2];

	$counter++;
	if($counter <= $workers){

		$curr_pid = $pid[$counter - 1] = fork();
		if($pid[$counter - 1] == 0){
			system("cd $path&&scrapy crawl tieba -s FILENAME=$tmpdir$file -a keywords='$keyword'");
			system("/usr/bin/env perl $path$generator $tmpdir$file > $tmpdir$file.html");
			last;
		}
		else{
			say("fork child done on counter = $counter, pid = $pid[$counter - 1]");
		}
	}
	else{
		foreach(@pid){
			waitpid($_, WNOHANG);
		}
		$counter = 0;
	}
}

if($curr_pid){
	while(wait() >= 0){
		usleep(100);
	}
	close($FH);
	system("/usr/bin/env perl ".$path.$sendmail);
}
