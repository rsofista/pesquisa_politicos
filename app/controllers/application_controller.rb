class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception

	def index
		@items = Item.all.where('exists(select 1 from item_terms where item_terms.item_id = items.id limit 1)').order :tag, :text
	end

	def item_terms
		render json: ItemTerm.select('item_terms.term_id, item_terms.qtd, terms.text').joins(:term).order('item_terms.qtd desc').where('item_terms.item_id' => params[:item].to_i).where('item_terms.qtd > 1').pluck('term_id', 'qtd', 'text')
	end

	def item_term_urls
		term = params[:term]

		if term.to_i.to_s == term.to_s
			render json: Url
				.select("url.id, coalesce(nullif(trim(title), ''), nullif(trim(title_ext), ''), 'Notícia') as title")
				.joins(:item_urls)
				.joins('inner join item_terms on (item_urls.item_id = item_terms.item_id)')
				.joins('inner join url_terms on (url_terms.url_id = item_urls.url_id and url_terms.term_id = item_terms.term_id)')
				.where('item_urls.item_id' => params[:item].to_i, 'item_terms.term_id' => params[:term].to_i)
				.order('item_terms.qtd desc')
				.pluck('id', 'title')
		else
			terms     = nil
			bad_terms = hash_bad_terms

			if bad_terms.has_key? params[:term]
				terms = bad_terms.map { |k, v| k if v == params[:term] }.compact
			else
				terms = hash_good_terms.map { |k, v| k if v == params[:term] }.compact
			end

			terms.map! { |t| "'#{t}'" }

			render json: Url
				.select("coalesce(nullif(trim(title), ''), nullif(trim(title_ext), ''), 'Notícia') as title, url")
				.joins(:item_urls)
				.joins('inner join item_terms on (item_urls.item_id = item_terms.item_id)')
				.joins('inner join url_terms on (url_terms.url_id = item_urls.url_id and url_terms.term_id = item_terms.term_id)')
				.where({'item_urls.item_id' => params[:item].to_i})
				.where("item_terms.term_id in (select id from terms where text in (#{terms.join(',')}))")
				.order('item_terms.qtd desc')
				.pluck('url', 'title')
		end
	end

	def item_main_terms
		good_terms = hash_good_terms
		bad_terms = hash_bad_terms
			 
		list_bad_terms  = (bad_terms.keys + bad_terms.values).uniq
		list_good_terms = (good_terms.keys + good_terms.values).uniq

		result   = ItemTerm.select('terms.text, qtd').joins(:term).where(terms: {text: list_bad_terms + list_good_terms}, item_id: params[:item].to_i).pluck('text', 'qtd')
		response = {sum: result.inject(0){ |sum, r| sum + r[1] }, terms: {}}

		result.each do |res|
			key_bad  = bad_terms[res[0]]
			key_good = good_terms[res[0]]

			if key_bad
				response[:terms][key_bad] ||= [0, false]
				response[:terms][key_bad][0] += res[1]
			else
				response[:terms][key_good] ||= [0, true]
				response[:terms][key_good][0] += res[1]
			end
		end

		response[:terms] = response[:terms].sort_by { |term, vals| vals[0] }.reverse

		render json: response
	end

	def url
		db_url = Url.select("text2 as text, url, coalesce(nullif(trim(title), ''), nullif(trim(title_ext), ''), 'Notícia') as title, date").find(params[:url_id])

		if db_url
			render json: db_url.to_json(only: [:text, :url, :title, :date])
		else
			render json: {text: 'Notícia não encontrada'}
		end
	end
private
	def hash_bad_terms
		return {
			'roubo' => 'roubo',
			'roubar' => 'roubo',
			'roubou' => 'roubo',

			'estelionato' => 'estelionato',

			'laranja' => 'laranja',
			'laranjas' => 'laranja',

			'desvio' => 'desvio',
			'desvios' => 'desvio',
			'desviar' => 'desvio',
			'desviaram' => 'desvio',
			'desviados' => 'desvio',

			'cassação' => 'cassação',
			'cassada' => 'cassação',
			'cassadas' => 'cassação',
			'cassado' => 'cassação',
			'cassados' => 'cassação',

			'lavagem' => 'lavagem',

			'propina' => 'propina',
			'propinas' => 'propina',

			'impeachment' => 'impeachment',

			'esquema' => 'esquema',
			'esquemas' => 'esquema',

			'renúncia' => 'renúncia',
			'renunciou' => 'renúncia',
			'renunciar' => 'renúncia',

			'prisão' => 'prisão',
			'preso' => 'prisão',
			'presa' => 'prisão',

			'cadeia' => 'cadeia',

			'bandidagem' => 'bandidagem',
			'bandido' => 'bandidagem',
			'bandida' => 'bandidagem',

			'acusação' => 'acusação',
			'acusações' => 'acusação',
			'acusado' => 'acusação',
			'acusados' => 'acusação',
			'acusada' => 'acusação',
			'acusadas' => 'acusação',

			'indiciação' => 'indiciação',
			'indiciado' => 'indiciação',
			'indiciados' => 'indiciação',
			'indiciada' => 'indiciação',
			'indiciadas' => 'indiciação',

			'mensalão' => 'mensalão',

			'impunidade' => 'impunidade',
			'impunide' => 'impunidade',
			'impunides' => 'impunidade',

			'punição' => 'punição',
			'punir' => 'punição',
			'punido' => 'punição',
			'punidos' => 'punição',
			'punida' => 'punição',
			'punidas' => 'punição',

			'crime' => 'crime',
			'crimes' => 'crime',
			'criminoso' => 'crime',
			'criminosos' => 'crime',
			'criminosa' => 'crime',
			'criminosas' => 'crime',
			'criminal' => 'crime',
			'criminais' => 'crime',

			'quadrilha' => 'quadrilha',

			'superfaturamento' => 'superfaturamento',
			'superfaturar' => 'superfaturamento',
			'superfaturado' => 'superfaturamento',
			'superfaturados' => 'superfaturamento',
			'superfaturada' => 'superfaturamento',
			'superfaturadas' => 'superfaturamento',

			'currupção' => 'currupção',
			'currupto' => 'currupção',
			'curruptos' => 'currupção',
			'currupta' => 'currupção',
			'curruptas' => 'currupção',

			'nepotismo' => 'nepotismo',

			'traição' => 'traição',
			'trair' => 'traição',
			'traidor' => 'traição',
			'traidora' => 'traição',
			'traidores' => 'traição',
			'traidoras' => 'traição',
			'traiu' => 'traição'
		}
	end

	def hash_good_terms
		return {
			'ajuda' => 'ajuda',
			'ajudas' => 'ajuda',
			'ajudar' => 'ajuda',
			'ajudarão' => 'ajuda',

			'democracia' => 'democracia',
			'democracias' => 'democracia',

			'desenvolvimento' => 'desenvolvimento',
			'desenvolvimentos' => 'desenvolvimento',

			'educação' => 'educação',
			'educar' => 'educação',
			'educando' => 'educação',

			'evolução' => 'evolução',
			'evoluções' => 'evolução',
			'evoluir' => 'evolução',
			'evoluirá' => 'evolução',
			'evoluirão' => 'evolução',
			'evoluiram' => 'evolução',

			'revolução' => 'revolução',

			'infraestrutura' => 'infraestrutura',
			'infraestruturas' => 'infraestrutura',

			'investimento' => 'investimento',
			'investimentos' => 'investimento',

			'liberdade' => 'liberdade',
			'libertar' => 'liberdade',

			'melhoria' => 'melhoria',
			'melhorias' => 'melhoria',
			'melhorar' => 'melhoria',
			'melhorando' => 'melhoria',
			'melhor' => 'melhoria',

			'rendimento' => 'rendimento',
			'render' => 'rendimento',
			'rendendo' => 'rendimento',

			'renovação' => 'renovação',
			'renovar' => 'renovação',
			'renovando' => 'renovação',
			'renovarão' => 'renovação',
			'renovam' => 'renovação',

			'resolvido' => 'resolvido',
			'resolvidos' => 'resolvido',
			'resolvida' => 'resolvido',
			'resolvidas' => 'resolvido',
			'resolução' => 'resolvido',
			'resolverá' => 'resolvido',
			'resolverão' => 'resolvido',

			'saúde' => 'saúde',

			'união' => 'união',
			'unir' => 'união',

			'justiça' => 'justiça',
			'justo' => 'justiça',
			'justa' => 'justiça',

			'aprimirar' => 'aprimirar',
			'aprimimoramento' => 'aprimirar',

			'alegria' => 'alegria',
			'alegrar' => 'alegria',

			'felicidade' => 'felicidade',
			'feliz' => 'felicidade',

			'emprego' => 'emprego',
			'empregar' => 'emprego'
		}
	end

	def hash_neutral_terms
		return {
			'terceirização' => 'terceirização',
			'terceirizar' => 'terceirização',
			'terceirizando' => 'terceirização',
			'terceirizarão' => 'terceirização',
			'terceirizariam' => 'terceirização',

			'tributação' => 'terceirização',
			'tributo' => 'terceirização',
			'tributar' => 'terceirização',

			'imposto' => 'imposto',
			'impostos' => 'imposto',

			'sindicalização' => 'sindicalização',
			'sindical' => 'sindicalização'
		}
	end
end