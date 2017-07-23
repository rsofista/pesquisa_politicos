require 'uri'
require 'google_custom_search_api'
require './db_classes'
require './thread_base'

GOOGLE_API_KEY   = 'AIzaSyD6RsUWErr065Ut1H8v6BWxXH6d4JYwT9Q'
GOOGLE_SEARCH_CX = '017545622426566837159:aus2ba3cwou'

#GOOGLE_SEARCH_CX = '017545622426566837159:4hvokcudnxe'

class WebSearch < ThreadBase
	def execute
		item = Item.order(date: :asc).limit(1)[0]

		if item
			google_results = nil
			urls = []

			10.times do |page_number|
				puts "WebSearch : query_web => '#{item.text}' [#{page_number+1}]"

				begin
					google_results = GoogleCustomSearchApi.search "notícia política #{item.text}", page: page_number

					if(
						(google_results.has_key? 'error') &&
						(google_results['error'].has_key? 'errors') &&
						(google_results['error']['errors'].is_a? Array) &&
						(google_results['error']['errors'].size > 0) &&
						(google_results['error']['errors'][0].has_key? 'domain') &&
						(google_results['error']['errors'][0]['domain'] == 'usageLimits')
					)
						self.sleep_time = 24*60*60
						return false
					end

					self.sleep_time = 10
				rescue Exception => e
					puts "\nEXCEPTION: WebSearch : query_web : error => '#{e.message}'\n"
					self.logs << e.message
					next
				end

				google_results['items'].each do |item|
					uri = URI item['link']

					if !uri.path.end_with?('.pdf') && !uri.path.end_with?('.doc') && !uri.path.end_with?('.docx')
						urls << {link: item['link'], title: item['title']}
					end
				end

				sleep 1
			end

			puts "WebSearch : save => #{urls.size}"

			ActiveRecord::Base.transaction do
				urls.each do |url|
					unless ItemUrl.joins(:item, :url).where(item_id: item.id, urls: {url: url[:link]}).exists?
						unless UrlsQueue.exists? item_id: item.id, url: url[:link]
							UrlsQueue.create! item_id: item.id, url: url[:link], title: url[:title], date: DateTime.now, qtd_errors: 0
						end
					end
				end

				item.date = DateTime.now
				item.save!
			end

			true
		else
			false
		end
	end
end

# {"error"=>
#   {"errors"=>
#     [{"domain"=>"usageLimits",
#       "reason"=>"dailyLimitExceeded",
#       "message"=>
#        "This API requires billing to be enabled on the project. Visit https://console.developers.google.com/billing?project=355505041070 to enable billing.",
#       "extendedHelp"=>"https://console.developers.google.com/billing?project=355505041070"}],
#    "code"=>403,
#    "message"=>
#     "This API requires billing to be enabled on the project. Visit https://console.developers.google.com/billing?project=355505041070 to enable billing."},
#  "items"=>[]}

