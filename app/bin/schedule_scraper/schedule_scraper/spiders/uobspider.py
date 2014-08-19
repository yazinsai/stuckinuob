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
    # Information in response.meta[]: 'uob_course_title', 'uob_course_code'

    # Extract course credits from title (it's between brackets)
    course_credits_raw = response.xpath('//u//b/text()').extract()[0]
    course_credits = re.search(r'\((\d)\)', course_credits_raw).group(1)

    # Extract exam timing for this lecture (from the first section)
    # Note: The exam timing is the same for all sections
    exam_row = response.xpath('//table//td/font/text()').extract()
    exam_date = exam_row[1]
    exam_start = exam_row[2]
    exam_end = exam_row[3]

    # Save the course to the DB
    course = {
      'credits': course_credits,
      'code': response.meta['uob_course_code'],
      'title': response.meta['uob_course_title'],
      'exam': {
        'date': exam_date,
        'start': exam_start,
        'end': exam_end,
      }
    }

    # Section information is temporarily stored in this list
    sections = []
    
    # Iterate through the sections
    for section in response.xpath('//p'):
      # Extract header information
      header = section.xpath('.//b/font[contains(@color, "#FF0000")]')
      if len(header) > 0:
        section  = header[0].xpath('text()').extract()
        lecturer = header[1].xpath('text()').extract()
        sections.append({ 
          'section': section, 
          'lecturer': lecturer,
          'lectures': []
          })

      # Would be great to extract lecture timings from here but the
      # HTML on the UoB site is malformed. The <p> tags are opened
      # but never closed, which means we'll need to do a separate 
      # search by <table> :(

    # Extract lecture timings
    section_index = 0
    for lectures in response.xpath('//table'):
      # Extract the lecture information - this excludes Header/Exam rows since 
      # we used 'text()', and the header/exam fields fall within <font> tags
      col = 0
      lecture_cols = lectures.xpath('.//td/text()').extract()
      while col < len(lecture_cols):
        # Take 4 columns at a time (day, start, end, room)
        # Store them in our sections list
        sections[section_index]['lectures'].append({
            'day': lecture_cols[col],
            'start_time': lecture_cols[col+1],
            'end_time': lecture_cols[col+2],
            'room': lecture_cols[col+3] 
          })

        # Increment columns pointer
        col += 4

      # Increment section
      section_index += 1

    # Save section details to the DB: TODO