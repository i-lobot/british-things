require 'readability'
require 'nokogiri'
require 'open-uri'
require 'json'

class ScrapeSurnames

  attr_accessor :names

  def initialize
    @path='data/surnames.json'
    load if File.exist? @path 
  end

  def crawl 
    @names = seek()
    sumup
  end

  def load
    @names = JSON.parse(File.read(@path))
    sumup
  end

  def save
    File.open(@path,"w") do |f|
      f.write(@names.to_json)
    end
  end

  def seek()
    urls = (2..57).collect { |x| "http://surname.sofeminine.co.uk/w/surnames/most-common-surnames-in-great-britain-#{x}.html" }
    urls.unshift "http://surname.sofeminine.co.uk/w/surnames/most-common-surnames-in-great-britain.html"
    urls.collect { |x| process x }.reduce :+
  end

  def process(url='http://surname.sofeminine.co.uk/w/surnames/most-common-surnames-in-great-britain.html')
    return Nokogiri::HTML(open(url)).css('h1 + table tr').collect do |node|
       name = node.css('a.nom').text.strip
       count = node.css('.compte').text.strip
       count.gsub!(/[^0123456789]/,'')
       [name.strip, count.strip.to_i]
    end
    .select { |row| (row[0].length < 100 and row[0]!='') }

  end
  
  def sample
    @number = Random.new.rand(0..@sum-1)
    count = 0
    idx = 0
    while @number > count  do
      count += @names[idx][1]
      idx+=1
    end
    return @names[idx]
  end

  private

  def sumup
    #@names = @names.sort { |x,y| x[1] <=> y[1] }
    @sum = names.collect { |x| x[1] }.reduce :+
  end
  
end
