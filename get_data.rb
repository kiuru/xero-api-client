require 'rubygems'
require 'xeroizer'
require 'json'
require 'yaml'
require 'date'
require 'logger'
require 'tzinfo'

if not defined?(Ocra)

	XeroLogger = Logger.new('xero.log', 'weekly')
	consumer_key = ARGV[0]
	from = ARGV[1]
	puts "Fetch journals which are modified since: #{from}"
	
	conf = YAML::load_file('conf.yaml')
	client = Xeroizer::PrivateApplication.new(consumer_key, "YOUR_OAUTH_CONSUMER_SECRET", conf["private_key"], {:logger => XeroLogger})
	
	# https://developer.xero.com/documentation/api/journals
	transactions = client.Journal.all(:modified_since => DateTime.parse(from), :order => "JournalNumber")
	#transactions = client.Journal.all(:modified_since => DateTime.parse(from), :order => "JournalNumber", :offset => 828)
	
	offset = ""
	data = ""
	transactions.each_with_index do | line, i |
		if (i == 0)
			data = "{ \"data\": ["
			data += "#{JSON.pretty_generate(line)}"
		else
			data += ", #{JSON.pretty_generate(line)}"
			offset = line["journal_number"]
		end
	end
	
	# Loop results while row count is 100 or more which means there might be still more results left
	total_journals = transactions.count
	puts "Fetch #{transactions.count} journals"
	while transactions.count >= 100
		transactions = client.Journal.all(:modified_since => DateTime.parse(from), :order => "JournalNumber", :offset => offset)
		puts "Fetch #{transactions.count} journals"
		total_journals += transactions.count
		transactions.each_with_index do | line, i |
			data += ", #{JSON.pretty_generate(line)}"
			offset = line["journal_number"]
		end
	end
	data += "]}"
	puts "Total: #{total_journals} journals"
	
	File.open("transactions.json","w") do |f|
		f.write(data)
	end
	
	puts "Transactions are written to the file"
end
