class Url < ActiveRecord::Base
	has_many :item_urls
	has_many :url_terms

	has_many :items, through: :item_urls
	has_many :terms, through: :url_terms
end
