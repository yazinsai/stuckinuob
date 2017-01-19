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
