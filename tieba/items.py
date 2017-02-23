# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class TiebaItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    pass

class ThreadItem(scrapy.Item):
    url = scrapy.Field()
    title = scrapy.Field()
    preview = scrapy.Field()
    author = scrapy.Field()
    tieba = scrapy.Field()
    date = scrapy.Field()
    keywords = scrapy.Field()

class NoneItem(scrapy.Item):
    url = scrapy.Field()
    title = scrapy.Field()
    preview = scrapy.Field()
    author = scrapy.Field()
    tieba = scrapy.Field()
    date = scrapy.Field()
    keywords = scrapy.Field()
