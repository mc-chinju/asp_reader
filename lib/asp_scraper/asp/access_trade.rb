class AspScraper::Asp::AccessTrades < AspScraper::Asp::Base
  def search
    agent.get(@login_page) do |page|
      form_action = "https://member.accesstrade.net/atv3/login.html"
      form = page.form_with(action: form_action) do |f|
        f.userId = @id
        f.userPass = @password
      end
      form.submit

      _page = agent.get(@data_page)
      target = _page.search(".report tbody tr")
      @ud_count  = target[1].search("td")[0].text
      @um_count  = target[1].search("td")[1].text
      @ud_reward = target[2].search("td")[0].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, "")
      @um_reward = target[2].search("td")[1].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, "")
      @dd_count  = target[3].search("td")[0].text
      @dm_count  = target[3].search("td")[1].text
      @dd_reward = target[4].search("td")[0].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, "")
      @dm_reward = target[4].search("td")[1].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, "")
    end
  end
end