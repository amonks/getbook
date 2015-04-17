require 'getbox/version'
require 'nokogiri'
require 'capybara/dsl'
require 'capybara-webkit'
require 'open-uri'
require 'json'


module Getbox
  include Capybara::DSL

  Capybara.default_driver = :webkit
  Capybara.app_host =  "http://app.gistboxapp.com"
  Capybara.run_server = false

  def prompt()
    puts "What's your github username?"
    username = gets.chomp
    puts "How about your password, eh??"
    password = gets.chomp

    puts "Where should I save your gists? [gists.json]"
    file = gets.chomp
    file = "gists.json" if file.empty?

    gists = getGistsFromSite(username, password)

    puts "Saving #{gists.length} gists to #{Dir.pwd}/#{file}"
    writeToFile(gists, file)
  end

  def getGistsFromSite(username, password)
    whitelist_urls

    puts "visiting app.gistboxapp.com"
    visit '/'
    click_on "Login"
    puts "filling out github login form"
    within("#login") do
      fill_in("login", :with => username)
      fill_in("password", :with => password)
      click_on "Sign in"
    end
    puts "gathering gists"
    getGistsFromHtml(page.html)
  end

  def getGistsFromFile(file)
    f = File.open(file)
    getGistsFromHtml(f)
  end

  def getGistsFromHtml(html)
    doc = Nokogiri::HTML(html)

    gists = []

    doc.css('div.split-gist').each do |gist|
      data = {}

      id = gist.attribute('data-id').value
      data[:url] = "https://gist.github.com/#{id}"

      data[:title] = gist.css('div.gist-name').inner_text

      data[:timestamp] = gist.css('span.gist-created-updated').inner_text

      description = gist.css('div.gist-description').inner_text.strip
      description = nil if description == 'No Description'
      data[:description] = description if description

      labels = []
      gist.css('span.gist-label').each {|label| labels.push label.inner_text}
      data[:labels] = labels

      gists.push data
    end

    gists
  end

  def writeToFile(object, file)
    json = JSON.pretty_generate(object)
    File.open(file, 'w') { |file| file.write(json) }
  end

  def whitelist_urls()
    page.driver.block_unknown_urls
    urls = [
      'app.gistboxapp.com',
      'github.com',
    ]
    urls.each { |url| page.driver.allow_url(url) }
  end
end
