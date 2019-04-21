class AspScraper::Asp::Felmat < AspScraper::Asp::Base
  def search
    agent.get(@login_page) do |page|
      form = page.form_with(name: "loginForm") do |f|
        f.p_username = @id
        f.p_password = @password
      end
      form.submit

      actions = ["daily", "monthly"]
      actions.each do |action|
        _page = agent.get("#{data_page}/#{action}")
        target = _page.search("tbody")[0]
        latest_data = target.search("tr")[0]
        term = action == "daily" ? "d" : "m"
        instance_variable_set("@u#{term}_count", latest_data.search("td")[4].text)
        instance_variable_set("@u#{term}_reward", latest_data.search("td")[5].text)
        instance_variable_set("@d#{term}_count", latest_data.search("td")[7].text)
        instance_variable_set("@d#{term}_reward", latest_data.search("td")[8].text)
      end
    when "access_trade"
      form_action = "https://member.accesstrade.net/atv3/login.html"
      form = page.form_with(action: form_action) do |f|
        f.userId = login_id
        f.userPass = password
      end
      form.submit

      _page = agent.get(data_page)
      target = _page.search(".report tbody tr")
      @ud_count  = target[1].search("td")[0].text
      @um_count  = target[1].search("td")[1].text
      @ud_reward = target[2].search("td")[0].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, "")
      @um_reward = target[2].search("td")[1].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, "")
      @dd_count  = target[3].search("td")[0].text
      @dm_count  = target[3].search("td")[1].text
      @dd_reward = target[4].search("td")[0].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, "")
      @dm_reward = target[4].search("td")[1].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, "")
    when "mosimo"
      form = page.form_with(id: "login-form") do |f|
        f.account = login_id
        f.password = password
      end
      form.submit

      actions = ["daily", "monthly"]
      actions.each do |action|
        _page = agent.get("#{@data_page}/#{action}")
        target = _page.search(".payment-table tbody")[0].search("tr").last
        term = action == "daily" ? "d" : "m"
        instance_variable_set("@u#{term}_count", target.search("td")[3].search("p")[0].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
        instance_variable_set("@u#{term}_reward", target.search("td")[3].search("p")[1].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
        instance_variable_set("@d#{term}_count", target.search("td")[4].search("p")[0].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
        instance_variable_set("@d#{term}_reward", target.search("td")[4].search("p")[1].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
      end
    end
  end
end