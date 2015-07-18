require 'getbook/version'
require 'pry'
require 'nokogiri'          # for parsing html
require 'capybara/dsl'      # to operate the headless browser
require 'capybara-webkit'   # the headless browser
require 'json'              # for pretty json output

Capybara::Webkit.configure do |config|
  config.allow_url("facebook.com")
  config.allow_url("*.akamaihd.net")
  config.allow_url("*.fbcdn.net")

  config.block_url("cs.atdmt.com")
  config.block_url("cx.atdmt.com")
  config.block_url("sync.liverail.com")
  config.block_url("*.nanigans.com")
  config.block_url("*.mediaplex.com")
end

module Getbook
  # configure Capybara
  include Capybara::DSL
  Capybara.default_driver = :webkit
  Capybara.app_host =  "https://facebook.com"
  Capybara.run_server = false

  def pry?(text)
    puts text
    puts "wanna Pry?"
    get_yes?
  end

  def get_yes?
    ! gets.chomp.downcase.include? "n"
  end

  # to use getbook interactively and write output to a file
  def mainPrompt
    creds = promptForLogin
    login(creds)

    profile

    scrollUntil ".uiHeader > .uiHeaderTop > .rfloat > .uiHeaderActions > a", text: "Highlights"

    begin
      click_link "#u_jsonp_8_4"
    rescue Capybara::ElementNotFound
      puts "couldn't find the link... saving page"
      page.save_page
    end
    click_on "All Stories"

    page.save_and_open_screenshot
    page.save_page
  end

  def scrollUntil(selector, options)
    scrolls = 0
    until canFind?(page, selector, options)
      scrolls += 1
      page.execute_script "window.scrollBy(0,100000)"
      puts "srcolled #{scrolls} times"
      page.save_and_open_screenshot
      page.save_page
    end
  end

  def canFind? page, selector, options
    begin
      page.find selector, options
    rescue Capybara::ElementNotFound
      return false
    end
    return true
  end

  def scrollBy(scrollPer)
    scrollCount = 0

    scrollPer.times do
      scrollCount += 1
      page.execute_script "window.scrollBy(0,10000)"
    end
    page.save_and_open_screenshot

    puts "I have scrolled #{scrollCount} times. should I scroll more?"

    scroll if get_yes?
  end

  def promptForPath(defaultPath)
    # doesn't support anything cool like ~, only a locally relative path
    puts "Where should I save? [#{defaultPath}]"
    path = gets.chomp
    path = defaultPath if file.empty?
    path
  end

  def promptForLogin
    # people shouldn't feel comfortable typing passwords into things.
    puts \
      "I'm about to ask for your facebook password. \n"\
      "You should probably read my source code\n"\
      "before you go through with this...\n"\
      "https://github.com/amonks/getbook/blob/master/lib/getbook.rb\n\n"\
      \
      "are you sure you want to continue? [yes/no]"

    raise "Well, OK then." unless get_yes?

    puts "What's your facebook username?"
    username = gets.chomp
    puts "How about your password, eh??"
    password = gets.chomp

    {
      username: username,
      password: password
    }
  end

  # method to go to facebook.com, and log in
  def login(creds)
    puts "visiting facebook.com"
    visit "/"

    puts "filling out facebook login form"
    within("#login_form") do
      fill_in("email", :with => creds[:username])
      fill_in("pass", :with => creds[:password])
      click_on "Log In"  # to facebook!
    end
  end

  # method to visit a user's profile
  def profile
    puts "What's your profile url??"
    profile = gets.chomp

    puts "visiting profile"

    url = "/#{profile}"
    visit url
  end

  # convenience wrapper for json-and-print
  def writeToFile(object, file)
    json = JSON.pretty_generate(object)
    File.open(file, 'w') { |f| f.write(json) }
  end
end
