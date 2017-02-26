#!/usr/bin/env perl
#
use JSON;
use Cwd qw(abs_path);
use utf8;
use File::stat;
use Time::localtime;
use File::Basename;
use Try::Tiny;

use open ':std', ':encoding(UTF-8)';

$path = dirname(abs_path(__FILE__)).'/';
open($fh, '<:encoding(UTF-8)', $ARGV[0]) or die "open file failed.";

print("<html>\n");
print("<head>\n");
print("<meta charset=\"utf-8\" />\n");
print("<title>Table of items</title>\n");
print("</head><body>\n");
my $wc = `wc -l < $ARGV[0]`;
chomp;
$wc =~ s/\s//g;
print("$wc results generated at ". ctime(stat($fh)->ctime) . "<br>\n");
print("<table border='1'>\n");
print("<tr><th>标题</th><th>作者</th><th>贴吧</th><th>预览</th><th>日期</th><th>地址</th></tr>\n");

while(<$fh>){
	try{
		chomp;
		$json = JSON->new->utf8->decode($_);
		print("<tr>\n");
		print("<td>". $json->{'title'}.	"</td>\n");
		print("<td>". $json->{'author'}.	"</td>\n");
		print("<td>". $json->{'tieba'}.	"</td>\n");
		print("<td>". $json->{'preview'}.	"</td>\n");
		print("<td>", $json->{'date'}.	"</td>\n");
		print("<td><a href=\"", $json->{'url'}.	"\" >link</a></td>\n");
		print("</tr>\n");
	}catch{
		next;
	}
}
close($fh);
open($append_fh, '<:encoding(UTF-8)', $path . "append.html") or die "can not read append file.";
my @append = <$append_fh>;
close($append_fh);
print("</table>@append</body></html>\n");
