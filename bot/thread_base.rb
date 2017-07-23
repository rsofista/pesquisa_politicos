class ThreadBase
	attr_accessor :logs
	attr_accessor :sleep_time

	def initialize
		self.logs = []
		self.sleep_time = 10
	end

	def do_loop
		while true
			begin
				puts "#{self.class.name} : loop"

				unless self.execute
					puts "#{self.class.name} : sleep => #{self.sleep_time}s"

					sleep self.sleep_time
				end
			rescue Exception => e
				puts "\n\nEXCEPTION: #{self.class.name} : execute => '#{e.message}'\n\n"
			ensure
				self.save_logs
			end
		end
	ensure
		puts "finalizando"
	end

	def save_logs
		unless self.logs.empty?
			time     = Time.now
			dir_name = "logs/#{self.class.name}/#{time.strftime '%Y-%m-%d'}"

			unless File.exists? dir_name
				FileUtils.mkdir_p dir_name
			end

			File.write "#{dir_name}/#{time.strftime '%H_%M_%S'}.log", self.logs.join("\n")
		end
	rescue Exception => e
		puts "\nEXCEPTION: Logs : save_logs => '#{e.message}'\n"
	ensure
		self.logs = []
	end
end
