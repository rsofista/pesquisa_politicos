require 'readability'
require 'open-uri'
require 'uri'
require 'htmlentities'
require 'cgi'
require './db_classes'
require './thread_base'

class WebCrawler < ThreadBase
	def execute
		url_queue = UrlsQueue.order(date: :asc).limit(1)[0]

		if url_queue
			url     = Url.find_by url: url_queue.url
			content = nil
			html    = nil

			unless url
				puts "WebCrawler : crawl => '#{url_queue.url}'"

				begin
					begin
						html = open(url_queue.url).read
					rescue OpenURI::HTTPRedirect => redirect
						html = open(redirect.uri).read
					end

					document = Readability::Document.new(html, tags: ['div', 'p']) 
					content  = document.content
					content  = content.to_s.gsub(/[\n\s+]/, ' ').gsub('<div>', ' ').gsub('</div>', ' ').gsub('<p>', ' ').gsub('</p>', ' ').squeeze(' ').strip
				rescue Exception => e
					puts "\nEXCEPTION: WebCrawler : Readability(open) => '#{e.message}'\n"
					self.logs << e.message

					if url_queue.qtd_errors < 3
						puts "\n\n#{self.class.name} => 3 erros, movendo ao fim da lista\n\n"
						url_queue.date = DateTime.now
						url_queue.qtd_errors += 1
						url_queue.save!
					else
						puts "\n\n#{self.class.name} => 9 erros, removendo da lista\n\n"
						Url.create url: url_queue.url, html: nil, text: nil, title: url_queue.title, date: DateTime.now
						url_queue.delete

						return false
					end

					html    = nil
					content = nil
				end
			end

			transaction_error = false

			ActiveRecord::Base.transaction do
				unless content.nil?
					begin
						content.encode!('UTF-8')
						content.force_encoding('UTF-8')
					rescue Exception => e
						puts "\nEXCEPTION: WebCrawler : content.force_encoding => '#{e.message}'\n"
						content = nil
					end
				end

				unless html.nil?
					begin
						html.encode!('UTF-8')
						html.force_encoding('UTF-8')
					rescue Exception => e
						puts "\nEXCEPTION: WebCrawler : html.force_encoding => '#{e.message}'\n"
						html = nil
					end
				end

				unless url
					begin
						title = document.html.title.to_s != '' ? document.html.title : url_queue.title
						url = Url.create! url: url_queue.url, html: html, text: content, text2: document.content, title_ext: url_queue.title, title: title , date: DateTime.now
					rescue Exception => e
						puts "\nEXCEPTION: WebCrawler : Url.create! => '#{e.message}'\n"
						transaction_error = true
					end
				end

				unless transaction_error
					ItemUrl.create! item_id: url_queue.item_id, url_id: url.id, stemmed: false

					url_queue.delete
				end
			end

			if transaction_error
				ActiveRecord::Base.transaction do
					url = Url.create! url: url_queue.url, text: nil, title: url_queue.title, date: DateTime.now
					
					ItemUrl.create! item_id: url_queue.item_id, url_id: url.id, stemmed: false

					url_queue.delete
				end
			end

			sleep 3
		else
			false
		end
	rescue Exception => e
		puts "\nEXCEPTION: WebCrawler : do_stuff => '#{e.message}'\n"
		self.logs << e.message

		false
	end
end
