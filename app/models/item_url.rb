class ItemUrl < ActiveRecord::Base
	belongs_to :item
	belongs_to :url
end
