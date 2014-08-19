from scrapy.spider import Spider
from scrapy.selector import Selector
from scrapy.http import Request, FormRequest
import urlparse
import os, sys, re

class UOBSpider(Spider):
  name = "uob"
  allowed_domains = ["uob.edu.bh"]
  start_urls = [
    "http://www.online.uob.edu.bh/cgi/enr/schedule2.abrv?prog=1&cyer=2014&csms=1"
  ]

  def parse(self, response):
    # We get a list of course blocks (e.g. ACC, ITCE)

    # Extract the links (Careful: these are relative, not absolute)
    relative_links = response.xpath('//a/@href').extract()

    for link in relative_links:
      # Generate absolute link
      absolute_link = urlparse.urljoin(response.url, link)

      # Crawl it
      yield Request(url=absolute_link, callback=self.parse_course_list)

  def parse_course_list(self, response):
    # We're on the course list page (e.g. for ITCE, we get ITCE101, ITCE102..)

    # Extract the links, and course information
    relative_links = response.xpath('//a[contains(@target, "main")]/@href').extract()
    titles = response.css('a[target="main"]').xpath('text()').extract()
    codes = response.css('font[color="#000000"]').xpath("text()").extract()
    count = 0

    for link in relative_links:
      # Generate absolute link
      absolute_link = urlparse.urljoin(response.url, link)

      # Crawl it
      yield Request(url=absolute_link, callback=self.parse_section_list,
        meta = {'uob_course_title': titles[count], 'uob_course_code': codes[count]})
      count+=1

  def parse_section_list(self, response):
    # We're on the section page for the course (e.g. sections for ITCE202)

    # print response.meta['uob_course_title']

    # Extract course information (credits)
    course_credits_raw = response.xpath('//u//b/text()').extract()[0]
    course_credits = re.search(r'\((\d)\)', course_credits_raw).group(1)

    # Extract exam timing for this lecture (from the first section)
    # Note: The exam timing is the same for all sections
    exam_row = response.xpath('//table//td/font/text()').extract()
    exam_date = exam_row[1]
    exam_start = exam_row[2]
    exam_end = exam_row[3]

    # Save the course to the DB

    # Iterate through the sections
    for section in response.xpath('//p'):
      # Extract header information
      header = section.xpath('.//b/font[contains(@color, "#FF0000")]')
      section  = header[0].xpath('text()').extract()
      lecturer = header[1].xpath('text()').extract()

      # Would be great to extract lecture timings from here but the
      # HTML on the UoB site is malformed. The <p> tags are opened
      # but never closed, which means we'll need to do a separate 
      # search by <table> :(

    # Extract lecture timings
    for lectures in response.xpath('//table'):
      # Extract the lecture information (excludes Header/Exam rows since we used 'text()')
      lecture_rows = lectures.xpath('.//td/text()').extract()
      i = 0
      while i < len(lecture_rows):
        # Take 4 at a time (day,start,end,room)
        day = lecture_rows[i]
        start_time = lecture_rows[i+1]
        end_time = lecture_rows[i+2]
        room = lecture_rows[i+3]

        #Save the lecture to the DB: TODO
        i += 4