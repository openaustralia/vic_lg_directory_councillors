require 'scraperwiki'
require 'mechanize'

# Remove councillor whatnot
def simplify_name(text)
  if text.split(" ").first == "Cr"
    text.split(" ")[1..-1].join(" ")
  else
    text
  end
end

def scrape_council(url)
  agent = Mechanize.new
  page = agent.get(url)
  council = page.at("h1").inner_text
  website_h = page.search("h2").find{|h| h.inner_text == "Website"}
  website = website_h.next_element.inner_text
  h = page.search("h2").find{|h| h.inner_text == "Councillors"}
  block = h.next_element.inner_html.split("<br>")
  block[1..-1].each do |line|
    if line.split(" - ")[0].strip == "Unsubdivided"
      ward = nil
    else
      ward = line.split(" - ")[0].strip
    end

    if line.split(" - ")[1..-1].join(" - ").strip =~ /<strong>\(Mayor.*\)<\/strong>/
      name = simplify_name(line.split(" - ")[1..-1].join(" - ").strip.split("<strong>").first.strip)
      position = "mayor"
    else
      name = simplify_name(line.split(" - ")[1..-1].join(" - ").strip)
      position = nil
    end

    record = {
      "council" => council,
      "ward" => ward,
      "councillor" => name,
      "position" => position,
      "council_website" => website
    }
    p record
    ScraperWiki.save_sqlite(["council", "councillor"], record)
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

urls.each {|url| scrape_council(url)}
