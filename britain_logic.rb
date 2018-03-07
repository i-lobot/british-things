require './surnames.rb'
require 'twitter_ebooks'


class BritainLogic

  attr_accessor :surnames, :male, :female

  def initialize
    @surnames = Surnames.new
    @male = (IO.readlines 'data/male.txt').collect { |x| x.strip }
    @female = (IO.readlines 'data/female.txt').collect { |x| x.strip }
    @titles_male = (IO.readlines 'data/titles_male.txt').collect { |x| x.strip }
    @titles_female = (IO.readlines 'data/titles_female.txt').collect { |x| x.strip }
    @places_model = Ebooks::Model.load("model/places.model")
  end

  def generate
    text=""
    which = rand(0..1)
    until text != "" and text.length <= 280
      if which==0
        text = marriage
      else
        text = birth
      end
    end
    text
  end

  def genName(gender=nil, no_title=false, is_couple=false, force_surname=nil, has_middle=nil)
  
    gender = rand(0..1) if gender==nil

    # is_couple implies gender=1 for now

    if gender==1 
      given = @male
      title = @titles_male.sample
    else
      given = @female 
      title = @titles_female.sample
    end


    if has_middle == nil
      has_middle = rand(0..1)
    end

    if has_middle and rand(0..3)==0
        has_middle=2
    end

    has_middle = 0 if not has_middle

    given = (has_middle+1).times.collect do |x|
      name = given.sample
      name = @surnames.sample if x>0 and rand(0..1)==1
      name
    end
    given = given.reduce { |x,y| "#{x} #{y}" }
      
    if force_surname 
      sur = force_surname
    else
      sur = @surnames.sample
    end

    if is_couple
      given += ' & '+@female.sample
    end

    suffix = ''
    suffix = ' ' + %w( OBE MBE KBE ).sample if rand(0..20)==0

    if no_title
      return "#{given} #{sur}"
    end

    "#{title} #{given} #{sur}#{suffix}"

  end

  def birth
    gender = rand(0..1)
    pronoun = %w(her his)[gender]
    sur = @surnames.sample
    baby = genName(gender,true, false, sur, 1)
    couple = genName(1, true, true, sur, false)
    place = @places_model.make_statement

    day = weekday 

    [
      "#{baby} was born to #{pronoun} parents #{couple} of #{place}.",
      "#{baby} was born to #{pronoun} parents #{couple} of #{place} on #{day}.",
      "#{baby} was born to #{pronoun} parents #{couple} of #{place} last #{day}.",
    ].sample 
  end


  def marriage

    gay = rand(0..10)==0

    if gay
      gender = rand(0..1)
      genders = [gender, gender]
    else
      genders = [1,0]
    end

    names = genders.collect { |x| genName x }

    places = (0..2).collect { @places_model.make_statement }
    places[2]=places[0] if rand(0..4)==0 
    #places[1]=places[0] if rand(0..4)==0 

    ages = genAges(18..50)

    names.each_with_index do |item, index|
      ages[index] += rand(5..10) if not item.match /^M[rs]/ and ages[index] < 28
    end

    verb = %w( wed married ).sample
    ceremony = %w( Christian Jewish Catholic Protestant Muslim Wiccan Norse pagan traditional Buddhist secular Hindu casual simple ).sample

    strings = [
      "#{names[0]}, #{ages[0]}, of #{places[0]}, #{verb} #{names[1]}, #{ages[1]}, of #{places[1]}, in a #{ceremony} ceremony at #{places[2]}.",
      "#{names[0]}, of #{places[0]}, #{verb} #{names[1]}, of #{places[1]}, in a #{ceremony} ceremony at #{places[2]}.",
      "#{names[0]}, #{ages[0]}, #{verb} #{names[1]}, #{ages[1]}, in a #{ceremony} ceremony at #{places[2]}.",
      "#{names[0]} #{verb} #{names[1]} in a #{ceremony} ceremony at #{places[2]}.",
      "#{names[0]} #{verb} #{names[1]} at #{places[2]}.",
      "#{names[0]}, of #{places[0]}, #{verb} #{names[1]}, of #{places[1]}, at #{places[2]}.",
      "#{names[0]}, #{ages[0]}, #{verb} #{names[1]}, #{ages[1]}, at #{places[2]}.",
      "#{names[0]}, #{verb} #{names[1]} in a #{ceremony} ceremony at #{places[2]}.",
      "#{names[0]}, of #{places[0]}, #{verb} #{names[1]}, of #{places[1]}, in a #{ceremony} ceremony at #{places[2]}.",
      "#{names[0]}, and #{names[1]}, of #{places[0]}, #{verb} in a #{ceremony} ceremony at #{places[2]}.",
      "#{names[0]}, and #{names[1]}, of #{places[0]}, #{verb} at #{places[2]}.",
      "#{names[0]}, #{ages[0]}, and #{names[1]}, #{ages[1]}, both of #{places[0]}, #{verb} at #{places[2]}.",
      "#{names[0]}, #{ages[0]}, and #{names[1]}, #{ages[1]}, both of #{places[0]}, #{verb} in a #{ceremony} ceremony at #{places[2]}.",
    ].sample

  end

  def genAges(range)
    ages = (0..1).collect { rand(range) }

    if ages[1] > ages[0] and rand(0..4) != 0
      ages[0]+=rand(5..10)
    end
    ages
  end

  def weekday
    %w( Monday Tuesday Wednesday Thursday Friday Saturday Sunday).sample
  end

end
