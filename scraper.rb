#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('.MsoTableGrid').first.css('tr').drop(1).each do |tr|
    tds = tr.css('td')
    data = { 
      name: tds[1].text.tidy.gsub(/^Hon /,''),
      constituency: tds[0].text.tidy,
      party: "Independent",
      term: 15,
      source: url,
    }
    puts data
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

scrape_list('http://www.gov.nu/wb/pages/parliament/assembly.php')
