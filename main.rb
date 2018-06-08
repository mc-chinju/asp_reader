require "mechanize"

agent = Mechanize.new
page = agent.get("http://google.com")

p page
