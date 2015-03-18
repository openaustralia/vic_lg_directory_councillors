#require 'scraperwiki'
require 'mechanize'

def scrape_council(url)
  agent = Mechanize.new
  page = agent.get(url)
  council = page.at("h1").inner_text
  h = page.search("h2").find{|h| h.inner_text == "Councillors"}
  block = h.next_element.inner_html.split("<br>")
  block[1..-1].each do |line|
    if line.split("-")[0].strip == "Unsubdivided"
      ward = nil
    else
      ward = line.split("-")[0].strip
    end

    record = {
      "council" => council,
      "ward" => ward,
      "councillor" => line.split("-")[1..-1].join("-").strip
    }
    p record
    #ScraperWiki.save_sqlite(["council", "councillor"], record)
  end
end

agent = Mechanize.new

page = agent.get("http://www.dtpli.vic.gov.au/local-government/find-your-local-council")

urls = page.at("#councils").parent.search("a").map {|a| a["href"]}
# Ignore the last link because it's for contact details
if urls[-1] == "http://www.dtpli.vic.gov.au/local-government/local-government-contact-details"
  urls = urls[0..-2]
else
  raise "Unexpected form of last link"
end
#p urls

urls.each {|url| scrape_council(url)}

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
