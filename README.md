# Stuck in UoB

## Setup

Setup virtualenv [Optional]:
```shell
virtualenv venv
source venv/bin/activate
```

Run crawler to pull the latest schedule to the SQLite database:
```shell
pip install -r requirements.txt
cd app/bin/schedule_scraper
scrapy crawl uob
```

Run the rails application:
```
rails s
```

## About the project

This project helps students at the University of Bahrain put together working schedules. While it's designed for this university, a lot of care has been taken to ensure that you can adapt this to other universities without much trouble.

First, let's explain the structure we're using at the university of Bahrain.

### Courses, Sections and Lectures
Students at the university select from a list of **Courses** on their academic plan &mdash; ultimately leading to their graduation (assuming they don't flunk said courses). 

Each course has a number of **Sections** (one or more) with specific lecture timings and instructor. If a student can't make a particular time, then they can pick from a number of other options that might work. **Lectures** are simply that: slots where the student is expected to attend for that particular class. They are the same every week throughout the semester.

# Project Structure

## 1. Scraper

### Database

## 2. Application

### Steps
- Check that the exam dates of the selected courses don't clash. If they do, halt and scream.
- Check that the lectures don't clash.

### Clash-check Algorithm

#### Assumptions made
- We won't be checking for clashes in the same section (e.g. lecuters + labs). The assumption is that the registration office is competent enough to ensure that the lectures in the same section do not contradict themselves.
- There will be no lectures right before / after midnight (11:59PM, 12:01AM). This may affect how the algorithm works on the edges of the weekly schedule
- Lectures follow the "UMTWH" naming convention &mdash; representing Sunday, Monday, Tuesday, Wednesday and Thursday respectively.

## Ideas for future development
- Update the web tool to allow students to filter schedules by preference for:
  - Fit the most lectures in the fewest days
  - Mornings/later classes
  - Particular instructors
  - Fix a particular section, and juggle the others
