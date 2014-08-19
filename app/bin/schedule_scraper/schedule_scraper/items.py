# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy

class Course(scrapy.Item):
  code = scrapy.Field()
  title = scrapy.Field()
  prerequisites = scrapy.Field()
  credits = scrapy.Field()
  exam_date = scrapy.Field()
  exam_start = scrapy.Field()
  exam_end = scrapy.Field()
  last_fetched = scrapy.Field(serializer=str)

class Section(scrapy.Item):
  days = scrapy.Field()
  start_time = scrapy.Field()
  end_time = scrapy.Field()
  room = scrapy.Field()

class Lecture(scrapy.Item):
  number = scrapy.Field()
  instructor = scrapy.Field()
  notes = scrapy.Field()