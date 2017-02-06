#!/usr/bin/env perl
#
use Cwd qw(abs_path);
use File::Basename;
use Digest::CRC qw(crc32);
use Encode qw(decode_utf8);

use open ':std', ':encoding(UTF-8)';

require "./config.pl";

my $maillist = $g_maillist;

$path = dirname(abs_path(__FILE__)).'/';
open(my $fh, '>>:encoding(UTF-8)', $path.$maillist) or die "failed open file";
my @config = map{decode_utf8($_, 1)} @ARGV;
$config[2] = crc32($config[0]).'.jl';
print $fh join(':', @config)."\n";
close($fh);
