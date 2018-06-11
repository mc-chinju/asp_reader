require "mechanize"
require "csv"
require "pry"

# Settings
asp_info = YAML.load_file("asp.yml")
security = YAML.load_file("security.yml")
USER_AGENT = "Windows Mozilla"
# AFFILIATES = ["a8", "felmat", "access_trade", "amazon_associate", "mosimo", "rentrax"]
AFFILIATES = ["a8","felmat"]

agent = Mechanize.new
agent.user_agent = USER_AGENT

# Prepare csv template
CSV.open("data.csv", "w") do |csv|
  csv << ["アフィリエイトサイト", "本日発生件数", "本日発生報酬", "本日承認件数", "本日承認報酬", "当月発生件数", "当月発生報酬", "当月承認件数", "当月承認報酬"]
end

AFFILIATES.each do |affiliate|
  login_page = asp_info[affiliate]["login"]
  data_page  = asp_info[affiliate]["data"]

  login_id = security[affiliate]["id"]
  password = security[affiliate]["password"]

  agent.get(login_page) do |page|
    case affiliate
    when "a8"
      form = page.form_with(name: "asLogin") do |f|
        f.login = login_id
        f.passwd = password
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

        _page = agent.get("#{data_page}?action=#{action}")
        target = _page.search(search_target)
        latest_data = target.search("tr")[latest_data_line]
        instance_variable_set("@#{action}_count",  latest_data.search("td")[count_line].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
        instance_variable_set("@#{action}_reward", latest_data.search("td")[reward_line].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, ""))
      end
    when "felmat"
      form = page.form_with(name: "loginForm") do |f|
        f.p_username = login_id
        f.p_password = password
      end
      form.submit

      actions = ["daily", "monthly"]
      actions.each do |action|
        _page = agent.get("#{data_page}/#{action}")
        target = _page.search("tbody")[0]
        latest_data = target.search("tr")[0]
        confirmed = action == "daily" ? "d" : "m"
        instance_variable_set("@u#{confirmed}_count", latest_data.search("td")[4])
        instance_variable_set("@u#{confirmed}_reward", latest_data.search("td")[5])
        instance_variable_set("@d#{confirmed}_count", latest_data.search("td")[7])
        instance_variable_set("@d#{confirmed}_reward", latest_data.search("td")[8])
      end
    when "access_trade"
    when "amazon_associate"
    when "mosimo"
    when "rentrax"
    when "presco"
    else
      raise "対応していません"
    end

    CSV.open("data.csv", "a") do |csv|
      csv << [affiliate, @ud_count, @ud_reward, @dd_count, @dd_reward, @um_count, @um_reward, @dm_count, @dm_reward]
    end
  end
end
