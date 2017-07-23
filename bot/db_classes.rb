require 'fileutils'

if RUBY_PLATFORM == 'java'
	require 'activerecord-jdbc-adapter'
else
	require 'active_record'
end

ActiveRecord::Base.establish_connection(adapter: 'postgresql', host: 'localhost', port: 5432, database: 'tcc', username: 'role_tcc', password: 'tcc')
ActiveRecord::Base.connection.execute "alter user role_tcc set search_path to public"

if not ActiveRecord::Base.connection.table_exists? :items
	ActiveRecord::Base.connection.create_table :items do |t|
		t.text     :text
		t.datetime :date
	end
end

if not ActiveRecord::Base.connection.table_exists? :terms
	ActiveRecord::Base.connection.create_table :terms do |t|
		t.text    :text
		t.integer :qtd
	end
end

if not ActiveRecord::Base.connection.table_exists? :urls
	ActiveRecord::Base.connection.create_table :urls do |t|
		t.text     :url
		t.text     :text
		t.text     :html
		t.text     :term_ids
		t.text     :title
		t.datetime :date
	end
end

if not ActiveRecord::Base.connection.table_exists? :item_terms
	ActiveRecord::Base.connection.create_table :item_terms do |t|
		t.integer :item_id
		t.integer :term_id
		t.integer :qtd
	end
end

if not ActiveRecord::Base.connection.table_exists? :item_urls
	ActiveRecord::Base.connection.create_table :item_urls do |t|
		t.integer :item_id
		t.integer :url_id
		t.boolean :stemmed
	end
end

if not ActiveRecord::Base.connection.table_exists? :url_terms
	ActiveRecord::Base.connection.create_table :url_terms do |t|
		t.integer :url_id
		t.integer :term_id
		t.integer :qtd
	end
end

if not ActiveRecord::Base.connection.table_exists? :urls_queue
	ActiveRecord::Base.connection.create_table :urls_queue do |t|
		t.integer  :item_id
		t.datetime :date
		t.text     :url
		t.text     :title
		t.integer  :qtd_errors
	end
end

if not ActiveRecord::Base.connection.table_exists? :ignore
	ActiveRecord::Base.connection.create_table :ignore, id: false do |t|
		t.text :text
	end
end

if not ActiveRecord::Base.connection.table_exists? :host_ignore
	ActiveRecord::Base.connection.create_table :host_ignore, id: false do |t|
		t.text :text
	end
end

ActiveRecord::Base.connection.execute 'create index if not exists items_date_idx on items(date)'
ActiveRecord::Base.connection.execute 'create index if not exists item_urls_item_url_stemmed_idx on item_urls(item_id, url_id, stemmed)'
ActiveRecord::Base.connection.execute 'create index if not exists item_terms_item_term_idx on item_terms(item_id, term_id)'
ActiveRecord::Base.connection.execute 'create index if not exists urls_queue_date_idx on urls_queue(date)'
ActiveRecord::Base.connection.execute 'create index if not exists terms_text_idx on terms(text)'
ActiveRecord::Base.connection.execute 'create index if not exists ignore_text_idx on ignore(text)'
ActiveRecord::Base.connection.execute 'create index if not exists host_ignore_text_idx on host_ignore(text)'
ActiveRecord::Base.connection.execute 'create index if not exists urls_url_idx on urls(url)'
ActiveRecord::Base.connection.execute 'create index if not exists url_terms_url_term_idx on url_terms(url_id, term_id)'

class Url < ActiveRecord::Base
	has_many :item_urls
	has_many :url_terms

	has_many :items, through: :item_urls
	has_many :terms, through: :url_terms
end

class Term < ActiveRecord::Base
	has_many :url_terms
	has_many :item_terms

	has_many :urls,  through: :url_terms
	has_many :items, through: :item_terms
end

class ItemTerm < ActiveRecord::Base
	belongs_to :item
	belongs_to :term
end

class ItemUrl < ActiveRecord::Base
	belongs_to :item
	belongs_to :url
end

class Item < ActiveRecord::Base
	has_many :item_urls
	has_many :item_terms

	has_many :urls,  through: :item_urls
	has_many :terms, through: :item_terms
end

class UrlTerm < ActiveRecord::Base
	belongs_to :term
	belongs_to :url
end

class UrlsQueue < ActiveRecord::Base
	self.table_name = 'urls_queue'
end

class Ignore < ActiveRecord::Base
	self.table_name = 'ignore'
end

class HostIgnore < ActiveRecord::Base
	self.table_name = 'host_ignore'
end
