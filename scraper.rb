#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'scraped'
require 'scraperwiki'
require 'pry'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('.MsoTableGrid').first.css('tr').drop(1).map do |tr|
    tds = tr.css('td')
    {
      name:         tds[1].text.tidy.gsub(/^Hon /, ''),
      constituency: tds[0].text.tidy,
      party:        'Independent',
      source:       url,
    }
  end
end

data = scrape_list('http://www.gov.nu/wb/pages/parliament/assembly.php')
data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']
ScraperWiki.save_sqlite(%i[name], data)

# Archive some other pages for later parsing
open('http://www.gov.nu/wb/pages/parliament/cabinet.php')
open('http://www.gov.nu/wb/pages/ministries.php')
