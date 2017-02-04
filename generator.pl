#!/usr/bin/env perl
#
use JSON;
use Cwd;
use utf8;
use File::stat;
use Time::localtime;
#use Data::Dumper qw(Dumper);

use open ':std', ':encoding(UTF-8)';

open($fh, '<:encoding(UTF-8)', $ARGV[0]) or die "open file failed.";

print("<html>\n");
print("<head>\n");
print("<meta charset=\"utf-8\" />\n");
print("<title>Table of items</title>\n");
print("</head>\n");
my $wc = `wc -l < $ARGV[0]`;
print("$wc results generated at ". ctime(stat($fh)->ctime) . "<br>\n");
print("<table border='1'>\n");
print("<tr><th>标题</th><th>作者</th><th>贴吧</th><th>预览</th><th>日期</th><th>地址</th></tr>\n");

while(!eof($fh)){
	my $line = readline($fh);
	chomp($line);
	$json = JSON->new->utf8->decode($line);
	print("<tr>\n");
	print("<td>". $json->{'title'}.	"</td>\n");
	print("<td>". $json->{'author'}.	"</td>\n");
	print("<td>". $json->{'tieba'}.	"</td>\n");
	print("<td>". $json->{'preview'}.	"</td>\n");
	print("<td>", $json->{'date'}.	"</td>\n");
	print("<td><a href=\"", $json->{'url'}.	"\" >link</a></td>\n");
	print("</tr>\n");
}
close($fh);
print("</table></html>\n");
