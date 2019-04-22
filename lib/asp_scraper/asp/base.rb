module AspScraper::Asp
  class Base
    attr_reader :id, :password, :login_url, :data_url
    class AspScraper::Asp::NotFoundAspInYaml < StandardError ;end

    USER_AGENT = "Windows Mozilla"

    def initialize(id:, password:)
      @id = id
      @password = password

      urls = read_urls_from_yml
      @login_url = urls["login"]
      @data_url = urls["data"]

      set_agent
    end

    private

      def read_urls_from_yml
        yml = YAML.load_file("lib/asp_scraper/asp.yml")
        asp_name = self.class.to_s.split("::")[-1].underscore
        yml[asp_name]
      rescue
        raise AspScraper::Asp::NotFoundAspInYaml
      end

      def set_agent
        @agent = Mechanize.new
        @agent.user_agent = USER_AGENT
      end
  end
end