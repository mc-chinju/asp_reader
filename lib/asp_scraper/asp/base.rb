module AspScraper::Asp
  class Base
    attr_reader :id, :password

    def initialize(id:, password:)
      @id = id
      @password = password
    end
  end
end