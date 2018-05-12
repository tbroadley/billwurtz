require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'capybara/rspec'
require 'json'
require 'open-uri'

include Capybara::DSL
include Capybara::RSpecMatchers

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end

Capybara.default_driver = :poltergeist

def sanitize(filename)
  # Bad as defined by wikipedia: https://en.wikipedia.org/wiki/Filename#Reserved_characters_and_words
  # Also have to escape the backslash
  bad_chars = [ '/', '\\', '?', '%', '*', ':', '|', '"', '<', '>', '.']
  bad_chars.each do |bad_char|
    filename.gsub!(bad_char, '')
  end
  filename
end

['songs', 'jazz'].each do |category|
  puts "\n#{category}\n"
  visit "http://www.billwurtz.com/#{category}.html"

  all('td:nth-child(2) > a:not([href^=store])').each do |song|
    song_name = song.text
    song_url = song[:href]
    puts song_name
    file_path = "../../../Music/Songs/billwurtz/#{category}/#{sanitize(song_name)}.mp3"
    unless File.exist?(file_path)
      download = open(song_url)
      IO.copy_stream(download, file_path)
    end
  end
end
