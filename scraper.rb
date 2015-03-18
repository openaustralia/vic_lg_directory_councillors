#require 'scraperwiki'
require 'mechanize'

agent = Mechanize.new

page = agent.get("http://www.dtpli.vic.gov.au/local-government/find-your-local-council")

urls = page.at("#councils").parent.search("a").map {|a| a["href"]}
# Ignore the last link because it's for contact details
if urls[-1] == "http://www.dtpli.vic.gov.au/local-government/local-government-contact-details"
  urls = urls[0..-2]
else
  raise "Unexpected form of last link"
end
p urls

#
# # Find somehing on the page using css selectors
# p page.at('div.content')
#
# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries. You can use whatever gems are installed
# on Morph for Ruby (https://github.com/openaustralia/morph-docker-ruby/blob/master/Gemfile) and all that matters
# is that your final data is written to an Sqlite database called data.sqlite in the current working directory which
# has at least a table called data.
