class AspScraper::Asp::Mosimo < AspScraper::Asp::Base
  def search
    agent.get(@login_page) do |page|
      form = page.form_with(id: "login-form") do |f|
        f.account = @id
        f.password = @password
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