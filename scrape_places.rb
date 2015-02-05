require 'readability'
require 'nokogiri'
require 'open-uri'

class ScrapePlaces

  def initialize
    load
  end

  def load
    places = seek()
    @names = places.collect do |url|
      towns = process url
      towns.each { |x| puts x }
      towns
    end
    .collect.reduce :+
    #puts @names

  end

  def seek(url='http://en.wikipedia.org/wiki/Category:Lists_of_United_Kingdom_locations_by_name')
    return Nokogiri::HTML(open(url)).css('#mw-pages a').select do |item|
      item.text.match /locations: /
    end
    .collect do |item|
       #puts item.text.strip
       "http://en.wikipedia.org"+item["href"]
    end 
  end

  def process(url='http://en.wikipedia.org/wiki/List_of_United_Kingdom_locations:_Co-Col')
    return Nokogiri::HTML(open(url)).css('td.fn.org a').collect do |town|
       text = town.text.strip
       text.gsub! /\(.*/, ''
       text.gsub! /disambiguation .*/, ''
       text.gsub! /citation .*/, ''
       text
    end
    .select { |x| x.strip != '' }

  end

end
