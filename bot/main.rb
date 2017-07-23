require './db_classes'
require './web_search'
require './web_crawler'
require './stemmer'

threads = []

1.times do |i|
	threads << Thread.new { WebSearch.new.do_loop }
end

1.times do |i|
	threads << Thread.new { WebCrawler.new.do_loop }
end

1.times do |i|
	threads << Thread.new { Stemmer.new.do_loop }
end

puts 'Main : join'

threads.map(&:join)
