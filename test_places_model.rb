require 'twitter_ebooks'

model = Ebooks::Model.load("model/places.model")
puts model.make_statement
