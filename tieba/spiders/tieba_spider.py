import scrapy

from tieba.items import ThreadItem
from urllib.parse import quote_plus
from bs4 import BeautifulSoup

tieba_url = "http://tieba.baidu.com/f/search/res?ie=utf-8&qw=%s"
tieba_base_url = "http://tieba.baidu.com"

class TiebaSpider(scrapy.Spider):
    name = "tieba"

    def start_requests(self):
        keywords_string = getattr(self, 'keywords', None)
        keywords = keywords_string.split()
        if keywords is None:
            raise NotConfigured('Keyword not set')
        print('Current keywords:')
        for keyword in keywords:
            print("%s" % keyword)
        encoded_querystring = quote_plus(' '.join(keywords))
        url = tieba_url % encoded_querystring
        yield scrapy.Request(url=url, callback=self.parse)

    def parse(self, response):
        div_spost = response.xpath('//div[@class="s_post"]')
        for div in div_spost:

            thread_url = div.xpath('.//span[@class="p_title"]/a[@class="bluelink"]/@href').extract_first()
            thread_title = BeautifulSoup(div.xpath('.//span[@class="p_title"]/a').extract_first(), 'lxml').get_text()
            thread_preview = BeautifulSoup(div.xpath('.//div[@class="p_content"]').extract_first(), 'lxml').get_text()
            thread_author = div.xpath('.//a[not(@data-fid)]/font/text()').extract_first()
            thread_tieba = div.xpath('.//a[@class="p_forum"]/font/text()').extract_first()
            thread_date = div.xpath('.//font[@class="p_green p_date"]/text()').extract_first()

            thread_url = tieba_base_url + thread_url

            item = ThreadItem()
            item['url'] = thread_url
            item['title'] = thread_title
            item['preview'] = thread_preview
            item['author'] = thread_author
            item['tieba'] = thread_tieba
            item['date'] = thread_date
            yield item

        next_page = response.xpath('//a[@class="next"]/@href').extract_first()
        if(next_page is not None):
            url = tieba_base_url + next_page
            yield scrapy.Request(url=url, callback=self.parse)
