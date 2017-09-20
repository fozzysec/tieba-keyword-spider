#!/usr/bin/env perl
use utf8;
use Digest::CRC qw(crc32);
use open ':std', ':encoding(UTF-8)';
use Encode qw(decode);
use feature qw(say);
use Cwd qw(abs_path);
use File::Basename qw(dirname);

my $old_conf = $ARGV[0];
open FI, '<:encoding(UTF-8)', $old_conf or die $!;
while(<FI>){
	chomp;
	next if /^(\s*(#.*)?)?$/;
	my @conf = split(':', $_);
	my $keywords = $conf[0];
	my $email = $conf[1];
	my @filenames = split('\.', $conf[2]);
	my $filename = $filenames[0];
	say("$filename:$keywords:15:filters/none.conf:$email");
}
close(FI);
