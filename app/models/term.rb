class Term < ActiveRecord::Base
	has_many :url_terms
	has_many :item_terms

	has_many :urls,  through: :url_terms
	has_many :items, through: :item_terms
end
