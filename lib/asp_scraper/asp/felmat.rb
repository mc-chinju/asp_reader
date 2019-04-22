class AspScraper::Asp::Felmat < AspScraper::Asp::Base
  def search
    @agent.get(@login_url) do |page|
      form = page.form_with(name: "loginForm") do |f|
        f.p_username = @id
        f.p_password = @password
      end
      form.submit

      actions = ["daily", "monthly"]
      actions.each do |action|
        _page = @agent.get("#{@data_url}/#{action}")
        target = _page.search("tbody")[0]
        latest_data = target.search("tr")[0]
        term = action == "daily" ? "d" : "m"
        instance_variable_set("@u#{term}_count", latest_data.search("td")[4].text)
        instance_variable_set("@u#{term}_reward", latest_data.search("td")[5].text)
        instance_variable_set("@d#{term}_count", latest_data.search("td")[7].text)
        instance_variable_set("@d#{term}_reward", latest_data.search("td")[8].text)
      end
    end

    return @ud_count, @ud_reward, @dd_count, @dd_reward, @um_count, @um_reward, @dm_count, @dm_reward
  end
end