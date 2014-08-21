from scrapy.spider import Spider
from scrapy.selector import Selector
from scrapy.http import Request, FormRequest
from scrapy.xlib.pydispatch import dispatcher
from scrapy import signals
import urlparse
import os, sys, re
import sqlite3

# The path to the database that we're using
DATABASE_PATH = "../../../../db/development.sqlite3"

class UOBSpider(Spider):
  name = "uob"
  allowed_domains = ["uob.edu.bh"]
  start_urls = [
    "http://www.online.uob.edu.bh/cgi/enr/schedule2.abrv?prog=1&cyer=2014&csms=1"
  ]

  def __init__(self, *args, **kwargs):
    # Attach to signals API to process triggers ()
    dispatcher.connect(self.spider_opened, signal=signals.spider_opened)
    dispatcher.connect(self.spider_closed, signal=signals.spider_closed)
    super(UOBSpider, self).__init__(*args, **kwargs)

  def spider_opened(self, spider):
    # Create our database
    self.db = sqlite3.connect(DATABASE_PATH)
    self.cursor = self.db.cursor()

    # Create tables
    self.cursor.executescript("""
    DROP TABLE IF EXISTS courses;
    CREATE TABLE courses (id INTEGER PRIMARY KEY, code TEXT, title TEXT, prerequisites VARCHAR(255), credits INT, exam_date DATE, exam_start INT, exam_end INT, created_at DATETIME, updated_at DATETIME);

    DROP TABLE IF EXISTS sections;
    CREATE TABLE sections (id INTEGER PRIMARY KEY, number TEXT, instructor TEXT, notes TEXT, course_id INT, created_at DATETIME, updated_at DATETIME);

    DROP TABLE IF EXISTS lectures;
    CREATE TABLE lectures (id INTEGER PRIMARY KEY, days TEXT, start_time INT, end_time INT, room TEXT, section_id INT, created_at DATETIME, updated_at DATETIME);
    """)

  def spider_closed(self, spider):
    # Commit the changes and close
    self.db.commit()
    self.db.close()

  def parse(self, response):
    # We get a list of course blocks (e.g. ACC, ITCE)

    # We'll need a selector to parse the HTML
    sel = Selector(response)

    # Extract the links (Careful: these are relative, not absolute)
    relative_links = sel.xpath('//a/@href').extract()

    for link in relative_links:
      # Generate absolute link
      absolute_link = urlparse.urljoin(response.url, link)

      # Crawl it
      yield Request(url=absolute_link, callback=self.parse_course_list)

  def parse_course_list(self, response):
    # We're on the course list page (e.g. for ITCE, we get ITCE101, ITCE102..)

    # We'll need a selector for this response too
    sel = Selector(response)

    # Extract the links, and course information
    relative_links = sel.xpath('//a[contains(@target, "main")]/@href').extract()
    titles = sel.css('a[target="main"]').xpath('text()').extract()
    codes = sel.css('font[color="#000000"]').xpath("text()").extract()

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

    # You guessed it .. another selector
    sel = Selector(response)

    # Extract course credits from title (it's between brackets)
    course_credits_raw = sel.xpath('//u//b/text()').extract()[0]
    course_credits = re.search(r'\((\d*)\)', course_credits_raw).group(1)

    # Extract exam timing for this lecture (from the first section)
    # Note: The exam timing is the same for all sections
    exam_row = sel.xpath('//table//td/font/text()').extract()
    if len(exam_row) >= 4 and exam_row[1] != '00:00':
      # Got an exam
      exam_date = exam_row[1]
      exam_start = exam_row[2]
      exam_end = exam_row[3]
    else:
      # There's no exam
      exam_date = exam_start = exam_end = 0

    # Save the course to the DB
    self.cursor.execute('INSERT INTO courses(code, title, prerequisites, credits, exam_date, exam_start, exam_end) VALUES(:code, :title, :prerequisites, :credits, :exam_date, :exam_start, :exam_end)', {
        'code': response.meta['uob_course_code'],
        'title': response.meta['uob_course_title'],
        'prerequisites': '', # TODO
        'credits': course_credits,
        'exam_date': exam_date,
        'exam_start': time_to_int(exam_start),
        'exam_end': time_to_int(exam_end)
      })
    course_id = self.cursor.lastrowid

    # Section information is temporarily stored in this list
    sections = []
    
    # Iterate through the sections
    for section in sel.xpath('//p'):
      # Extract header information
      header = section.xpath('.//b/font[contains(@color, "#FF0000")]')

      # Is it a header or just an empty tag?
      if len(header) > 0:
        section  = header[0].xpath('text()').extract()[0]
        lecturer = header[1].xpath('text()').extract()[0]
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
    for lectures in sel.xpath('//table'):
      # Extract the lecture information - this excludes Header/Exam rows since 
      # we used 'text()', and the header/exam fields fall within <font> tags
      lecture_cols = lectures.xpath('.//td/text()').extract()
      col = 0
      while col < len(lecture_cols):
        # Take 4 columns at a time (day, start, end, room)
        # Store them in our sections list
        sections[section_index]['lectures'].append({
            'days': lecture_cols[col],
            'start_time': time_to_int(lecture_cols[col+1]),
            'end_time': time_to_int(lecture_cols[col+2]),
            'room': lecture_cols[col+3] 
          })
        # Increment columns pointer
        col += 4

      # Increment section
      section_index += 1

    # Iterate through the sections and save the details (section + lecture) to the DB
    for section in sections:
      # Save section details
      self.cursor.execute('INSERT INTO sections(number, instructor, notes, course_id) VALUES(:number, :instructor, :notes, :course_id)', {
        'number': section['section'],
        'instructor': section['lecturer'],
        'notes': '', # TODO
        'course_id': course_id # BUG: Why's the course_id never repeated?
        })
      section_id = self.cursor.lastrowid

      # Iterate through the lectures and save the details
      for lecture in section['lectures']:
        # Save lecture details
        self.cursor.execute('INSERT INTO lectures(days, start_time, end_time, room, section_id) VALUES(:days, :start_time, :end_time, :room, :section_id)', {
          'days': lecture['days'],
          'start_time': lecture['start_time'],
          'end_time': lecture['end_time'],
          'room': lecture['room'],
          'section_id': section_id
          })

def time_to_int(str_time):
  # This method converts the passed time (in the form 'HH:MM' to an integer value that can be used instead)
  if type(str_time) is int:
    # Wha'? Already an integer .. return it as is
    return str_time
  else:
    # You've come to the right place .. convert it to an integer
    pieces = str_time.split(':')
    return int(pieces[0])*60 + int(pieces[1])