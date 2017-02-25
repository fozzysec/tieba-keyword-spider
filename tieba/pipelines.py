# -*- coding: utf-8 -*-
import json
import urllib.request
import lxml.html
import html
import re
import logging
from functools import wraps
from scrapy.utils.python import get_func_args
from scrapy import Request
from lxml import etree
import http.cookiejar
from binascii import crc32
from scrapy.exceptions import DropItem
from scrapy.exceptions import CloseSpider

from tieba.items import ThreadItem, NoneItem

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
        if isinstance(item, ThreadItem):
            raise DropItem()

        data = dict(item)
        del data['keywords']
        line = json.dumps(data) + "\n"
        self.file.write(line.encode('utf-8'))
        return item

class DuplicatesPipeline(object):
    def __init__(self):
        self.thread_set = set()
    
    def process_item(self, item, spider):
        if isinstance(item, NoneItem):
            return item

        checksum = crc32(item['preview'].encode('utf-8'))
        if checksum in self.thread_set:
            raise DropItem("Duplicated content from %s" % item['author'])
        else:
            self.thread_set.add(checksum)
            return item

def callback_args(f):
    args = get_func_args(f)[2:]
    @wraps(f)
    def wrapper(spider, response):
        return f(spider, response,
                **{k:response.meta[k] for k in args if k in response.meta})
    return wrapper

class FilterPipeline(object):
    def __init__(self, filterlist, filteruserrank, crawler):
        self.cookiejar = http.cookiejar.CookieJar()
        self.filter_opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.cookiejar))
        self.filterlistname = filterlist
        self.userrank = int(filteruserrank)
        self.crawler = crawler

    @classmethod
    def from_crawler(self, crawler):
        filterlist = crawler.settings.get('FILTER')
        userrank = crawler.settings.get('USER_RANK')
        return self(
                filterlist = filterlist,
                filteruserrank = userrank,
                crawler = crawler
                )

    def open_spider(self, spider):
        fh = open(self.filterlistname, "r")
        if fh is None:
            raise CloseSpider("Can not open filterlist")
        self.filterlist = fh.read().splitlines()
        fh.close()

    @callback_args
    def process_response(self, response, item):
        anchor = item['url'].split('#')[1]
        print("%s get anchor: %s" % (response.url, anchor))

        doc = lxml.etree.HTML(response.body, etree.HTMLParser(encoding="utf-8"))
        try:
            div = doc.xpath('//a[@class="l_post_anchor" and @name="%s"]/following-sibling::div//div[@class="d_badge_lv"]' % anchor)
            current_rank = div[0]
            current_rank = int(current_rank.text)

            if(current_rank >= self.userrank):
                raise DropItem("found user rank(%d) >= USER_RANK(%d)" % (current_rank, self.userrank))

            div = doc.xpath('//div[@id="post_content_%s"]' % anchor)[0]

            post_content = etree.tostring(div, method="text", encoding='utf-8').decode('utf-8')
            post_content = html.unescape(post_content)

            for key in self.filterlist:
                if key in post_content:
                    raise DropItem("Filter keyword %s found in content, drop it" % key)

            for keyword in item['keywords']:
                if keyword not in post_content:
                    raise DropItem("keyword %s not found in content, drop it" % keyword)
        except DropItem as e:
            logging.log(logging.INFO, "DropItem: %s" % e)
        except IndexError:
            logging.log(logging.INFO, "Not reply, drop it")
        else:
            finalitem = NoneItem()
            finalitem.__dict__.update(item.__dict__)
            return finalitem

    def process_item(self, item, spider):
        if isinstance(item, NoneItem):
            return item

        self.item = item
        content_url = item['url']
        self.crawler.engine.crawl(
                Request(
                    url = content_url,
                    callback = self.process_response, meta={'item': item}
                    ),
                spider
                )
        raise DropItem
