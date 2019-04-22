class AspScraper::Asp::Rentracks < AspScraper::Asp::Base
  def search
    @agent.get(@login_url) do |page|
      form_action = "https://manage.rentracks.jp/manage/login/login_manage_validation"
      form = page.form_with(action: form_action) do |f|
        f.idMailaddress = @id
        f.idLoginPassword = @password
      end
      form.submit
      _page = @agent.get(@data_url)
      target = _page.search(".datatable tr")

      actions = ["daily", "monthly"]
      actions.each do |action|
        term = action == "daily" ? "d" : "m"
        instance_variable_set("@u#{term}_count", target[4].search("td")[3].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
        instance_variable_set("@u#{term}_reward", target[4].search("td")[5].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
        instance_variable_set("@d#{term}_count", target[7].search("td")[3].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
        instance_variable_set("@d#{term}_reward", target[7].search("td")[5].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
      end
    end

    return @ud_count, @ud_reward, @dd_count, @dd_reward, @um_count, @um_reward, @dm_count, @dm_reward
  end
end
