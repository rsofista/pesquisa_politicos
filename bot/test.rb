require "readability"
require "open-uri"

require 'pg'

# GOOGLE_SEARCH_PARAMS = {tbm: 'nws'}

source = open("http://g1.globo.com/tecnologia/games/noticia/2016/09/pokemon-go-por-tras-de-300-casos-de-policia-na-inglaterra-e-pais-de-gales.html").read

content = Readability::Document.new(source, tags: []).content

File.write('derp.html', content)

# Output a table of current connections to the DB
conn = PG.connect(dbname: 'db_test', user: 'lucas', password: 'lucas')
conn.exec( "SELECT * FROM pers_person" ) do |result|
  puts "      ID | Name"
  result.each do |row|
    puts " %7d | %-16s" %  row.values_at('pers_id', 'pers_name')
  end
end

