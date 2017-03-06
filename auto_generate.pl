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
	my $lv = $array[2];
	my $filter = $array[3];
	my $mail = $array[4];

	LOOP:
	$counter++;
	if($counter <= $workers){

		$curr_pid = $pid[$counter - 1] = fork();
		if($curr_pid == 0){
			system("cd $path&&scrapy crawl tieba -s FILENAME=$tmpdir$id.jl -s USER_RANK=$lv -s FILTER=$path$filter -a keywords='$keyword'");
			system("/usr/bin/env perl $path$generator $tmpdir$id.jl > $targetdir$id.html");

			foreach(split(/\|/, $mail)){
				system("mutt -e 'set content_type=text/html' -s '$keyword' $mail < $targetdir$id.html");
				say("mutt -e 'set content_type=text/html' -s '$keyword' $mail < $targetdir$id.html");
			}

			#terminate continue reading lines
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
		$counter = 0;
		goto LOOP;
	}
}

if($curr_pid){
	while(wait() >= 0){
		usleep(100);
	}
	close($fh);
}
