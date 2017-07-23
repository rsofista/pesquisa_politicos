file_name = ''
words = {}
total_words = {}

def save_file(file_name, words)
	file_str = ''

	words_arr = words.to_a.sort_by { |el| el[1] }

	words_arr.each do |el|
		file_str += el[1].to_s + ' ' + el[0] + "\n"
	end

	File.write(file_name + '.txt', file_str)
end

57.times do |num|
	begin
		file_name = "%.5d_.html" % (num + 1)
		puts file_name

		if File.exists? file_name
			file_content = File.read(file_name)

			words = {}

			# file_content.downcase.gsub(/[^a-z0-9\s]/i, ' ').split(' ').each do |word|
			file_content.downcase.gsub(/[^a-z\sáéíóúàâêôãõ]/i, ' ').split(' ').each do |word|
				if word.size > 3
					total_words[word] = words[word] ||= 0
					total_words[word] = words[word] += 1
				end
			end

			save_file(file_name, words)
		end
	rescue
		puts 'pau'
	end
end

save_file('0000' + file_name, words)
