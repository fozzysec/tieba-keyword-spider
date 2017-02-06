#!/usr/bin/env perl
#
use Cwd qw(abs_path);
use File::Basename;
use Digest::CRC qw(crc32);
use Encode qw(decode_utf8);

use open ':std', ':encoding(UTF-8)';

$path = dirname(abs_path(__FILE__)).'/';
open(my $input, '<:encoding(UTF-8)', $path.$ARGV[0]) or die "failed open input file";
open(my $output, '>:encoding(UTF-8)', $path.$ARGV[1]) or die "failed open output file.";
while(<$input>){
	my @config = split(/:/, $_);
	$config[2] = crc32($config[0]).'.jl';
	print join(':', @config)."\n";
	print $output join(':', @config)."\n";
}
close($input);
close($output);
