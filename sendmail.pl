#!/usr/bin/env perl
#
use Cwd qw(abs_path);
use File::Basename;
use MIME::Base64 qw(encode_base64);
use Encode;
use feature qw(say);
use utf8;

use open ':std', ':encoding(UTF-8)';

$path = dirname(abs_path(__FILE__)).'/';

require $path."config.pl";

my $maillist = $g_maillist;
my $tmpdir = $g_tmpdir;
my $sendgrid_enabled = $g_sendgrid_enabled;
my $gmail_enabled = $g_gmail_enabled;

sub init{
	my @currenttime = localtime(time);
	my $hour = $currenttime[2];
	say("Current hour: $hour, setting sendmail shedule");
	say("Global config:\t\tsendgrid_enabled: $sendgrid_enabled\tgmail_enabled: $gmail_enabled");
	#second mail per day
	if($sendgrid_enabled){
		if($hour >= 11 && $hour <= 22){
			$sendgrid_enabled = 0;
			$gmail_enabled = 1;
		}
		else{
			$sendgrid_enabled = 1;
			$gmail_enabled = 1;
		}
	}
	say("Adjusted config:\tsendgrid_enabled: $sendgrid_enabled\tgmail_enabled: $gmail_enabled");
}

sub sendmail_wrapper{
	my @conf = @_;
	my $mails = $conf[1];
	foreach(split(/\|/, $mails)){
#		if($_ =~ m/.*\@qq\.com/ && $sendgrid_enabled == 1){
#			sendgrid_sendmail($conf[0], $_, $conf[2]);
#		}
		if($sendgrid_enabled == 1){
			sendgrid_sendmail($conf[0], $_, $conf[2]);
		}
		elsif($gmail_enabled == 1){
			gmail_sendmail($conf[0], $_, $conf[2]);
		}
		elsif($sendgrid_enabled == 1 && $gmail_enabled == 0){
			sendgrid_sendmail($conf[0], $_, $conf[2]);
		}
		else{
			die("No sendmail method enabled");
		}
	}
}

sub gmail_sendmail{
	my @conf = @_;
	my $subject = $conf[0];
	my $to = $conf[1];

	my $cmd = "mutt -e 'set content_type=text/html' -s '$subject' $to < $tmpdir$conf[2].html";
	system($cmd);
	#say($cmd);
}

sub sendgrid_sendmail{
	my @conf = @_;
	my $subject = utf8::is_utf8($conf[0]) ? Encode::encode_utf8($conf[0]) : $conf[0];
	my $to = $conf[1];

	chomp(my $encoded_subject = encode_base64($subject));
	my $mime_subject = "=?utf-8?B?$encoded_subject?=";
	my $header = "Subject: =$mime_subject\nContent-Type: text/html; charset=utf-8\nMIME-Version: 1.0\nX-SMTPAPI: {\"asm_group_id\":2123, \"to\": [\"$to\"]}\n\n";
	open(HTML, '<:encoding(UTF-8)', "$tmpdir$conf[2].html") or die "can not open origin html file $tmpdir$conf[2].html";
	open(SENDGRID, '>:encoding(UTF-8)', "$tmpdir$conf[2].sendgrid.html") or die "can not create sendgrid html";
	my @origin_html = <HTML>;
	print SENDGRID $header;
	print SENDGRID @origin_html;
	close(HTML);
	close(SENDGRID);
	my $cmd = "msmtp -a sendgrid --from fozzy\@fozzy.co $to < $tmpdir$conf[2].sendgrid.html";
	system("$cmd");
	#say($cmd);
}

init();
open(my $FH, '<:encoding(UTF-8)', $path.$maillist) or die "failed open file";

while(<$FH>){
	chomp;
	next if /^(\s*(#.*)?)?$/;
	my @array = split(/:/, $_);
	sendmail_wrapper(@array);
}
close($FH);
