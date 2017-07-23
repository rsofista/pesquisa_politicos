require 'pry'
require './db_classes'
require './thread_base'
require 'active_support/multibyte/chars'

STEMMER_REGEX = /[0-9:;´`^~'"“”�\[\]\\\/|{}ªº¹²³!?@#$%*()_+=§£¢¬<>,.]/

class Stemmer < ThreadBase
	def execute
		item_url = ItemUrl.joins(:url).includes(:url).find_by stemmed: false

		if item_url
			puts "Stemmer : stemming => '#{item_url.url.url}'"

			ActiveRecord::Base.transaction do
				item_url.url.text.to_s.gsub(STEMMER_REGEX, ' ').split(' ').each do |word|
					if word.length > 2
						word = ActiveSupport::Multibyte::Chars.new(word).downcase.to_s

						unless Ignore.where(text: word).exists?
							term     = Term.find_or_create_by! text: word
							url_term = UrlTerm.find_or_create_by term_id: term.id, url_id: item_url.url_id

							term.qtd     = (term.qtd || 0) + 1
							url_term.qtd = (url_term.qtd || 0) + 1

							term.save!
							url_term.save!

							self.create_or_update_item_term! item_url.item_id, term.id
						end
					end
				end
			end

			item_url.stemmed = true
			item_url.save!

			true
		else
			false
		end
	end

	def create_or_update_item_term! item_id, term_id
		item_term = ItemTerm.find_by item_id: item_id, term_id: term_id

		if item_term
			item_term.qtd += 1
			item_term.save!
		else
			ItemTerm.create! item_id: item_id, term_id: term_id, qtd: 1
		end
	end
end
