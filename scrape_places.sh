#!/bin/sh
set -e
ruby  -r./scrape_places.rb  -e ScrapePlaces.new 2> /dev/null | tee corpus/places.txt
ebooks consume corpus/places.txt
