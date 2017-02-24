#!/usr/bin/env perl

use utf8;
use Cwd qw(abs_path);
use File::Basename;
use feature qw(say);
use open ':std', ':encoding(UTF-8)';
use Time::HiRes qw(usleep);

$path = dirname(abs_path(__FILE__)).'/';

require $path."config.pl";

my $generator = $g_generator;
my $tmpdir = $g_tmpdir;
my $workers = $g_workers;
my $generatelist = $g_generatelist;
my $targetdir = $g_targetdir;

open($fh, '<:encoding(utf-8)', $path.$generatelist) or die("can not open $path$generatelist: $!");

my $counter = 0;
my @pid = ($workers);

my $curr_pid = 1;

while(<$fh>){
	chomp;
	next if /^(\s*(#.*)?)?$/;
	my @array = split(/:/);
	my $id = $array[0];
	my $keyword = $array[1];
	my $filter = $array[2];

	$counter++;
	if($counter <= $workers){

		$curr_pid = $pid[$counter - 1] = fork();
		if($curr_pid == 0){
			system("cd $path&&scrapy crawl tieba -s FILENAME=$tmpdir$id.jl -s FILTER=$path$filter -a keywords='$keyword'");
			system("/usr/bin/env perl $path$generator $tmpdir$id.jl > $targetdir$id.html");
			last;
		}
		else{
			say("fork child done on counter = $counter, pid = $curr_pid");
		}
	}
	else{
		foreach(@pid){
			waitpid($_, WNOHANG);
		}
	}
}

if($curr_pid){
	while(wait() >= 0){
		usleep(100);
	}
	close($fh);
}
