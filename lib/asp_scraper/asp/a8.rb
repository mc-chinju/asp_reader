class AspScraper::Asp::A8 < AspScraper::Asp::Base
  def search
    agent.get(@login_page) do |page|
      form = page.form_with(name: "asLogin") do |f|
        f.login = @id
        f.passwd = @password
      end
      form.submit

      # unconfirmed => u, decided => d
      # month => m, daily => d
      actions = ["ud", "dd", "um", "dm"]
      actions.each do |action|
        latest_data_line = ["um", "dm"].include?(action) ? 1 : 2
        search_target = (action == "dd") ? "table" : ".reportTable1"

        count_line = 0
        reward_line = 0
        case action
        when "ud"
          count_line = 5
          reward_line = 6
        when "dd", "um"
          count_line = 3
          reward_line = 4
        when "dm"
          count_line = 1
          reward_line = 2
        end

        _page = agent.get("#{@data_page}?action=#{action}")
        target = _page.search(search_target)
        latest_data = target.search("tr")[latest_data_line]
        instance_variable_set("@#{action}_count",  latest_data.search("td")[count_line].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
        instance_variable_set("@#{action}_reward", latest_data.search("td")[reward_line].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
      end
    end
  end
end