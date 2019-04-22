class AspScraper::Asp::Mosimo < AspScraper::Asp::Base
  def search
    @agent.get(@login_url) do |page|
      form = page.form_with(id: "login-form") do |f|
        f.account = @id
        f.password = @password
      end
      form.submit

      actions = ["daily", "monthly"]
      actions.each do |action|
        _page = @agent.get("#{@data_url}/#{action}")
        target = _page.search(".payment-table tbody")[0].search("tr").last
        term = action == "daily" ? "d" : "m"
        instance_variable_set("@u#{term}_count", target.search("td")[3].search("p")[0].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
        instance_variable_set("@u#{term}_reward", target.search("td")[3].search("p")[1].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
        instance_variable_set("@d#{term}_count", target.search("td")[4].search("p")[0].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
        instance_variable_set("@d#{term}_reward", target.search("td")[4].search("p")[1].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
      end
    end

    return @ud_count, @ud_reward, @dd_count, @dd_reward, @um_count, @um_reward, @dm_count, @dm_reward
  end
end