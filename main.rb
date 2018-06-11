require "mechanize"
require "csv"
require "pry"

asp_info = YAML.load_file("asp.yml")

# Settings
asp_info = YAML.load_file("asp.yml")
security = YAML.load_file("security.yml")
USER_AGENT = "Windows Mozilla"
# AFFILIATES = ["a8", "felmat", "access_trade", "amazon_associate", "mosimo", "rentrax"]
AFFILIATES = ["a8"]

agent = Mechanize.new
agent.user_agent = "Windows Mozilla"

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

      _page = agent.get(data_page)
      table = _page.search(".reportTable1")
      latest_data = table.search("tr")[1]
      confirmed_count = latest_data.search("td")[1].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, "")
      confirmed_reward = latest_data.search("td")[2].text.gsub(/\r\n|\r|\n|\s|\t/, "").gsub(/[^\d]/, "")
      CSV.open("data.csv", "a") do |csv|
        csv << [affiliate, "-", "-", "-", "-", "-", "-", confirmed_count, confirmed_reward]
      end
    when "felmat"
    when "access_trade"
    when "amazon_associate"
    when "mosimo"
    when "rentrax"
    when "presco"
    else
      raise "対応していません"
    end
  end
end
