#!/usr/bin/env perl
#
use utf8;
use open ':std', ':encoding(UTF-8)';
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use Digest::CRC qw(crc32);
use feature qw(say);
use Encode qw(decode);
use UUID::Random qw(generate);
no warnings 'experimental::smartmatch';

$path = dirname(abs_path(__FILE__)).'/';
require $path."config.pl";
my $maillist = $g_maillist;

my $outfilename = "$path$maillist.". UUID::Random::generate();
open($fh, '<:encoding(UTF-8)', $path.$maillist) or die("cannot open maillist file: $path$maillist");
open($outfh, '>:encoding(UTF-8)', $outfilename) or die("cannot create tmp file: $outfilename");

@ARGV = map { decode('utf-8', $_) } @ARGV;

my @input_keywords = split(' ', $ARGV[0]);
my $mail = $ARGV[1];

my $addflag = 1;
my $dupflag = 0;
while(<$fh>){
	chomp;
	next if /^(\s*(#.*)?)?$/;
	my $counter = 0;
	my @conf = split(':', $_);
	my @keywords = split(' ', $conf[0]);

	foreach(@input_keywords){
		$counter++ if($_ ~~ @keywords);
	}
	#keywords matched
	if($counter == scalar @input_keywords && scalar @input_keywords == scalar @keywords){
		say("found existing record at line: $., content is: $_");
		$addflag = 0;
		my @addresses = split(/\|/, $conf[1]);
		if( $mail ~~ @addresses){
			say("duplicated email: $mail");
			$dupflag = 1;
			last;
		}
		say("appended to existing record");
		$conf[1] = $conf[1].'|'.$mail;
	}	
	print $outfh join(':', @conf)."\n";
}
close($fh);

#none existing record
if($addflag){
	my @conf = @ARGV;
	$conf[2] = crc32($conf[0]).".jl";
	print $outfh join(':', @conf)."\n";
	say("added new record");
}

close($outfh);

say("cleaning");
if(! $dupflag){
	rename($path.$maillist, "$path$maillist.bak") or die("backup maillist file failed");
	rename($outfilename, $path.$maillist) or do 
	{
		rename("$path$maillist.bak", $path.$maillist);
		die("can not overwrite $path$maillist");
	};
	unlink("$path$maillist.bak");
}
else{
	unlink($outfilename);
}
