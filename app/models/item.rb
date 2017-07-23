class Item < ActiveRecord::Base
	has_many :item_terms
	has_many :item_urls

	has_many :terms, through: :item_terms
	has_many :urls,  through: :item_urls
end
