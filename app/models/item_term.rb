class ItemTerm < ActiveRecord::Base
	belongs_to :item
	belongs_to :term
end
