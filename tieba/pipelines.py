# -*- coding: utf-8 -*-
import json
import urllib.request
import lxml.html
import html
import re
from lxml import etree
import http.cookiejar
from binascii import crc32
from scrapy.exceptions import DropItem
from scrapy.exceptions import CloseSpider

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html


class TiebaPipeline(object):
    def __init__(self, filename):
        self.filename = filename

    @classmethod
    def from_crawler(cls, crawler):
        setting_filename = crawler.settings.get('FILENAME')
        return cls(
                filename = setting_filename
                )

    def open_spider(self, spider):
        self.file = open(self.filename, 'wb')

    def close_spider(self, spider):
        if self.file is not None:
            self.file.close()

    def process_item(self, item, spider):
        data = dict(item)
        del data['keywords']
        line = json.dumps(data) + "\n"
        self.file.write(line.encode('utf-8'))
        return item

class DuplicatesPipeline(object):
    def __init__(self):
        self.thread_set = set()
    
    def process_item(self, item, spider):
        checksum = crc32(item['preview'].encode('utf-8'))
        if checksum in self.thread_set:
            raise DropItem("Duplicated content from %s" % item['author'])
        else:
            self.thread_set.add(checksum)
            return item

class FilterPipeline(object):
    def __init__(self, filterlist, filteruserrank):
        self.cookiejar = http.cookiejar.CookieJar()
        self.filter_opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.cookiejar))
        self.filterlistfilename = filterlist
        self.filteruserrank = filteruserrank

    @classmethod
    def from_crawler(self, crawler):
        filename = crawler.settings.get('FILTERLIST')
        userrank = crawler.settings.get('USER_RANK')
        return self(
                filterlist = filename,
                filteruserrank = userrank
                )

    def open_spider(self, spider):
        fh = open(self.filterlistfilename, "r")
        if fh is None:
            raise CloseSpider("Can not open filterlist")
        self.filterlist = fh.read().splitlines()
        fh.close()

    def process_url(self, url, item):
        anchor = url.split('#')[1]
        response = self.filter_opener.open(url)

        doc = etree.HTML(response.read(), etree.HTMLParser(encoding="utf-8"))
        div = doc.xpath('//a[@class="l_post_anchor" and @name="%s"]/following-sibling::div' % anchor)[0]
        current_rank = div.xpath('//div[@class="d_badge_lv"]')
        if current_rank is None:
            raise DropItem("not replay form, drop it")
        current_rank = current_rank[0]
        current_rank = int(current_rank.text)

        if(current_rank >= self.filteruserrank):
            raise DropItem("found user rank(%d) >= USER_RANK(%d)" % (current_rank, self.filteruserrank))

        div = doc.xpath('//div[@id="post_content_%s"]' % anchor)[0]

        post_content = etree.tostring(div, method="text", encoding='utf-8').decode('utf-8')
        post_content = html.unescape(post_content)

        for key in self.filterlist:
            if key in post_content:
                raise DropItem("Filter keyword %s found in content, drop it" % key)

        for keyword in item['keywords']:
            if keyword not in post_content:
                raise DropItem("keyword %s not found in content, drop it" % key)

    def process_item(self, item, spider):
        content_url = item['url']
        self.process_url(content_url, item)
        return item

