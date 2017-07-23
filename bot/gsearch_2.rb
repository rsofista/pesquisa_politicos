require 'readability'
require 'open-uri'
require 'uri'
require 'google_custom_search_api'

GOOGLE_API_KEY   = 'AIzaSyD6RsUWErr065Ut1H8v6BWxXH6d4JYwT9Q'
GOOGLE_SEARCH_CX = '017545622426566837159:aus2ba3cwou'

search_terms = ['luciano bulignon']
links = []
errors = []
result_count = 0

search_terms.each do |search_term|

  10.times do |page_number|

    begin
      google_results = GoogleCustomSearchApi.search("notícias #{search_term}", page: page_number)
    rescue Exception => e
      errors << e.message
      next
    end

    google_results['items'].each do |item|
      result_count += 1

      links << item['link']

      begin
        html = open(item['link']).read
      rescue Exception => e
        links[links.count -1] = "[error] #{links.last}"
        errors << e.message
      end

      main_html = Readability::Document.new(html, tags: []).content

      begin
        File.write("%.5d.html" % result_count, html)
        File.write("%.5d_.html" % result_count, main_html)
      rescue Exception => e
        errors << e.message
      end
    end
  end
end

begin
  File.write('links.txt', links.join("\n")) if not links.empty?
  File.write('errors.txt', errors.join("\n")) if not errors.empty?
rescue Exception => e
  puts e.message
end
