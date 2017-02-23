import scrapy

from tieba.items import ThreadItem
from urllib.parse import quote_plus
import lxml.html
import html
import re

tieba_url = "http://tieba.baidu.com/f/search/res?ie=utf-8&qw=%s"
tieba_base_url = "http://tieba.baidu.com"

class TiebaSpider(scrapy.Spider):
    name = "tieba"

    def start_requests(self):
        keywords_string = getattr(self, 'keywords', None)
        keywords = keywords_string.split()
        if keywords is None:
            raise NotConfigured('Keyword not set')
        self.keywords = keywords
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

            s = ''
            thread_title = ''
            title_node = div.xpath('.//span[@class="p_title"]/a').extract_first()
            if title_node is not None:
                title = lxml.html.fromstring(title_node)
                for node in title.xpath('node()'):
                    if isinstance(node, str):
                        s+=node
                    else:
                        s+=lxml.html.tostring(node, with_tail=False).decode('utf-8')
                s = re.sub('<em>', '<font color="red">', s)
                s = re.sub('</em>', '</font>', s)
                thread_title = html.unescape(s)

            s = ''
            thread_preview = ''
            preview_node = div.xpath('.//div[@class="p_content"]').extract_first()
            if preview_node is not None:
                preview = lxml.html.fromstring(preview_node)
                for node in preview.xpath('node()'):
                    if isinstance(node, str):
                        s+=node
                    else:
                        s+=lxml.html.tostring(node, with_tail=False).decode('utf-8')
                s = re.sub('<em>', '<font color="red">', s)
                s = re.sub('</em>', '</font>', s)
                thread_preview = html.unescape(s)

            thread_author = div.xpath('.//a[not(@data-fid)]/font/text()').extract_first()
            thread_tieba = div.xpath('.//a[@class="p_forum"]/font/text()').extract_first()
            thread_date = div.xpath('.//font[@class="p_green p_date"]/text()').extract_first()

            thread_url = tieba_base_url + thread_url

            item = ThreadItem()
            item['url'] = thread_url
            item['title'] = thread_title
            item['preview'] = thread_preview
            item['author'] = '' if thread_author == None else thread_author
            item['tieba'] = '' if thread_tieba == None else thread_tieba
            item['date'] = '' if thread_date == None else thread_date
            item['keywords'] = self.keywords
            yield item

        next_page = response.xpath('//a[@class="next"]/@href').extract_first()
        if(next_page is not None):
            url = tieba_base_url + next_page
            yield scrapy.Request(url=url, callback=self.parse)
