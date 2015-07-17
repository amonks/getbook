require 'getbook/version'
require 'nokogiri'          # for parsing html
require 'capybara/dsl'      # to operate the headless browser
require 'capybara-webkit'   # the headless browser
require 'json'              # for pretty json output

module Getbook

  # configure Capybara
  include Capybara::DSL
  Capybara.default_driver = :webkit
  Capybara.app_host =  "https://facebook.com"
  Capybara.run_server = false

  # to use getbook interactively and write output to a file
  def prompt()
    # people shouldn't feel comfortable typing passwords into things.
    puts \
      "I'm about to ask for your facebook password. \n"\
      "You should probably read my source code\n"\
      "before you go through with this...\n"\
      "https://github.com/amonks/getbook/blob/master/lib/getbook.rb\n\n"\
      \
      "are you sure you want to continue?"

    raise "Well, OK then." if gets.chomp.downcase.include? "no"

    puts "What's your facebook username?"
    username = gets.chomp
    puts "How about your password, eh??"
    password = gets.chomp
    puts "How about your profile url, eh??"
    profile = gets.chomp

    # doesn't support anything cool like ~, only a locally relative path
    puts "Where should I save your wall? [wall.html]"
    file = gets.chomp
    file = "wall.html" if file.empty?

    wall = getWallFromSite(username, password, profile)

    # puts "Saving #{wall.length} gists to #{Dir.pwd}/#{file}"
    writeToFile(wall, file)
  end

  # method to go to app.gistboxapp.com, and log in with github credentials
  def getWallFromSite(username, password, profile)
    # partly to avoid warnings, and partly to avoid hitting analytics
    # whitelist_urls

    puts "visiting facebook.com"
    visit '/'

    puts "filling out facebook login form"
    within("#login_form") do
      fill_in("email", :with => username)
      fill_in("pass", :with => password)
      click_on "Log In"  # to facebook!
    end

    puts "visiting wall"
    visit '/#{profile}'

    page.html
  end

  # convenience wrapper for json-and-print
  def writeToFile(object, file)
    json = JSON.pretty_generate(object)
    File.open(file, 'w') { |f| f.write(json) }
  end

  # set up capybara-webkit's whitelest
  def whitelist_urls()
    page.driver.block_unknown_urls  # block tracking and media, disable warnings
    urls = [
      'app.gistboxapp.com',         # whitelist the servers we need
      'github.com',
    ]
    urls.each { |url| page.driver.allow_url(url) }
  end
end
