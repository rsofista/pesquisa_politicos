require './db_classes'
require 'pry'
require 'nokogiri'
require 'readability'

i = 1
max = Url.maximum(:id)+1

erros_title = []
erros_text = []

while i < max
	u = Url.find_by(id: i)

	if u
		print u.id.to_s + ','
		begin
			u.title = Nokogiri::HTML(u.html).title
		rescue
			erros_title << u.id
		end
		begin
			u.text2 = Readability::Document.new(u.html, tags: ['div', 'p']).content
		rescue
			erros_text << u.id
		end

		u.save
	end

	i += 1
end

puts erros_title.to_s
puts erros_text.to_s
