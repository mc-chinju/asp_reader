require "asp_scraper/asp/a8"
require "asp_scraper/asp/access_trade"
require "asp_scraper/asp/felmat"
require "asp_scraper/asp/mosimo"
require "asp_scraper/asp/rentracks"

module AspScraper
  class Client
    class AspScraper::NotFoundModuleError < StandardError; end

    attr_reader :client

    def initialize(asp:, id:, password:)
      klass = Object.const_get("AspScraper::Asp::#{asp}")
      @client = klass.new(id: id, password: password)
    rescue NameError
      raise AspScraper::NotFoundModuleError
    end
  end
end
