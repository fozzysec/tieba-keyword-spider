#!/usr/bin/env perl
#
use JSON;
use Cwd;
use utf8;
use File::stat;
use Time::localtime;

use open ':std', ':encoding(UTF-8)';

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
}
close($fh);
my $append = <<APPEND;
		<p>To 各位大佬们:</p>

		<p>
		首先我很不确定QQ邮箱还能不能收到这封邮件（生无可恋.jpg）<br>
		非常非常非常抱歉的通知各位大佬，因为用的人太多了，然后要发送的邮件数量太多，QQ邮箱把我当作垃圾邮件封掉了。<br>
		被一连串发送失败的报警邮件炸醒的时候我就懵逼了，暗戳戳的戳了度娘一圈之后并没有发现有什么好的解决方案，然后那些可以解决的方法差不多都是购买一些付费群发邮件的云服务。然后我只是个吃土学生狗并不能买起，零花钱还都被狗比gww坑在外观上面了（萝莉烧银行卡有木有！），所以这里有两种解决方案：
		</p>

		<p>
		<font color="red">1.换一个邮箱地址</font>（墙裂推荐，比较简单，没有后患[划掉]）<br>
		邮件回复我新的邮箱地址或者在贴吧私信或留言都可以，我看到的话会及时更新。建议使用163之类的（再次画圈圈诅咒QQ邮箱一百次=A=)
		</p>

		<p>
		<font color="red">2.在QQ邮箱设置中添加域名白名单</font>（比较复杂，不推荐，只有一个邮箱而且是QQ邮箱的时候使用）<br>
		我在贴吧发了设置白名单的方法，QQ邮箱如果继续使用的话需要按照帖子里的设置来更新才可以正常收到邮件。<br>
		传送门:<a href="http://tieba.baidu.com/p/4965096439?pid=103679829717&cid=0#103679829717">戳我</a><br>
		</p>

		<p>
		如果还能收到这封邮件但是是在垃圾箱发现的，一定要移出垃圾箱然后添加白名单<br>
		本来我还有考虑过做成微信公众号，但是今天借亲友的订阅号试了之后发现只有企业号可以推送链接内容，而且链接的网站还需要备案。可是我看了服务号的申请流程需要营业执照和组织机构代码证之类的东西（这是什么鬼学生狗怎么可能会有！），所以微信公众号也只能放弃了，如果以后用的人越来越多的话我会考虑那个一个月89块钱的付费邮件发送云sendcloud。有代收号的大佬们有需要的话可以找我做定制版的这个抓取系统，但是每个月就要赞助89块钱来交这个付费邮件发送的服务。<br>
		但是这个东西对不需要定制版（例如需要5分钟刷新一次的代售号的大佬）的小伙伴是会一直免费下去的。
		</p>

		<p>
		PS: 文字版添加白名单方法<br>
		QQ邮箱-设置-反垃圾-白名单-设置域名白名单<br>
		输入fozzy.co<br>
		添加此域名到白名单
		</p>

		<p>
		絮絮叨叨的楼主终于说完啦，最后就是希望各位大佬们原谅这次出现的问题，这个东西虽然是免费的但是我会当做自己的兴趣尽可能的一直运营下去的，如果各位大佬蹲到了自己想要的号不妨向自己的亲友之类的推荐一下，我会不胜感激。<br>
		另外就是<font color="red">如果不想继续接收邮件的话直接回复邮件或者在贴吧留言</font>都可以，我看到了之后会及时处理。
		</p>
		<p>
		这套系统的功能我也会不断的改进和优化，有感兴趣的同属CS专业的码农小伙伴们欢迎沟通交流，企鹅号59346987。有企业服务号想添加这个功能的也可以找我商议，另外就是帖子里已经说了，这套系统是开源的，源码可以在github找到。（地址：<a href="https://github.com/fozzysec/tieba-keyword-spider">GitHub</a>）。
		</p>

		<p>
		最后的最后，这是我的女装PY照，请各位大佬息怒（递照片.jpg）。
		</p>

		<p>
		Best regards,<br>
		瑟瑟发抖的楼主
		</p>
APPEND
print("</table>$append</body></html>\n");
