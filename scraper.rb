require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'yaml'

# http://www.uitzendinggemist.nl/programmas?order=latest_broadcast_date_asc&page=80
$urls = Array.new
$programUrls = Array.new
$baseUrl = 'http://www.uitzendinggemist.nl'

def has_sub(path)
  url = "#{$baseUrl}#{path}"

  page = Nokogiri::HTML(open(url))
  data = Hash[page.xpath("//span/@*[starts-with(name(), 'data-')]").map{|e| [e.name,e.value]}]
  if data.nil?
    return false
  end

  return true
end

def find_episodes(url)
  puts "Finding episodes in #{url}"

  begin
    page = Nokogiri::HTML(open(url))
    links = page.css('#episodes li a').map { |link| link['href'] }

    if !has_sub(links.first)
      return false
    end

    links.each do |link |
      $urls.push(link)
    end

    nextPage = page.css('.pagination a.next_page')

    if nextPage.any?
      path = nextPage.map { |link| link['href'] }[0].to_s
      last_char = path[path.length-2, path.length-1]

      url = "#{$baseUrl}#{path}"
      if path.length < 2
        return
      end

      # Remove this part of you want to check all episodes
      if last_char.to_i < 30
        find_episodes(url)
      end
    end

  rescue
    puts "Not found episode #{url}"
  end

  return true
end

find_episodes('http://www.uitzendinggemist.nl/programmas/2237-wie-is-de-mol')
#find_episodes('http://www.uitzendinggemist.nl/programmas/962-pauw-witteman')
#find_episodes('http://www.uitzendinggemist.nl/programmas/989-de-wereld-draait-door')
#find_episodes('http://www.uitzendinggemist.nl/programmas/1225-pownews')
#find_episodes('http://www.uitzendinggemist.nl/programmas/292-nos-jeugdjournaal-avond')

$urls.each do |path |
  next if path == "#"

  url = "#{$baseUrl + path}"
  puts "Finding data in #{url}"
  page = Nokogiri::HTML(open(url))
  data = Hash[page.xpath("//span/@*[starts-with(name(), 'data-')]").map{|e| [e.name,e.value]}]

  if !data.nil?
    id = data['data-player-id']
    date = page.css('table.information tr')[1].css('td')[0].text

    filename = "subtitles/#{date.to_s}-#{id}.vtt"
    open(filename, 'wb') do |file|
      file << subtitle = open("http://e.omroep.nl/tt888/#{id}").read
    end
  end
end

# Simple loop to scrape all programs
=begin
i = 0

while i < 119 do
  url = "http://www.uitzendinggemist.nl/programmas?order=latest_broadcast_date_asc&page=#{i}"

  puts "Scraping #{url}"

  begin
    #table.information tr (2de) td text
    page = Nokogiri::HTML(open(url))
    links = page.css('ol.series.list > li > h2 > a').map { |link| link['href'] }
    links.each do |link |
      $programUrls.push(link)
    end

  rescue
    puts "Not found #{url}"
  end

  i += 1
end


$programUrls.each do |path |
  url = "#{$baseUrl}#{path}"
  find_episodes(url)
end

$urls.each do |path |
  next if path == "#"

  url = "#{$baseUrl + path}"
  puts "Finding data in #{url}"
  page = Nokogiri::HTML(open(url))
  data = Hash[page.xpath("//span/@*[starts-with(name(), 'data-')]").map{|e| [e.name,e.value]}]

  if !data.nil?
    id = data['data-player-id']
    date = page.css('table.information tr')[1].css('td')[0].text

    filename = "subtitles/#{date.to_s}-#{id}.vtt"
    open(filename, 'wb') do |file|
      file << subtitle = open("http://e.omroep.nl/tt888/#{id}").read
    end
  end
end
=end
