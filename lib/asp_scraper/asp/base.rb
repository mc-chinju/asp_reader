module AspScraper::Asp
  class Base
    attr_reader :id, :password, :login_url, :data_url
    class AspScraper::Asp::NotFoundAspInYaml < StandardError ;end

    def initialize(id:, password:)
      @id = id
      @password = password

      urls = read_urls_from_yml
      @login_url = urls["login"]
      @data_url = urls["data"]
    end

    private

      def read_urls_from_yml
        yml = YAML.load_file("asp.yml")
        asp_name = self.class.to_s.split("::")[-1].downcase
        yml[asp_name]
      rescue
        raise AspScraper::Asp::NotFoundAspInYaml
      end
  end
end