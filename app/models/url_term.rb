class UrlTerm < ActiveRecord::Base
	belongs_to :term
	belongs_to :url
end
