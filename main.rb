require "mechanize"
require "csv"

asp_info = YAML.load_file("asp.yml")

# For example: A8
ASP_LOGIN_PAGE = "https://www.a8.net"
ASP_DATA_PAGE = "https://pub.a8.net/a8v2/asResultReportAction.do?action=dm"
LOGIN_ID = asp_info["asp"]["a8"]["id"]
PASSWORD = asp_info["asp"]["a8"]["password"]

agent = Mechanize.new
agent.user_agent = "Windows Mozilla"
agent.get(ASP_LOGIN_PAGE) do |page|
  form = page.form_with(name: "asLogin") do |f|
    f.login = LOGIN_ID
    f.passwd = PASSWORD
  end
  form.submit

  _page = agent.get(ASP_DATA_PAGE)
  table = _page.search(".reportTable1")
  latest_data = table.search("tr")[1]
  date = latest_data.search("td")[0].text.gsub(/\r\n|\r|\n|\s|\t/, "")
  confirmed_count = latest_data.search("td")[1].text.gsub(/\r\n|\r|\n|\s|\t/, "")
  tax_included = latest_data.search("td")[2].text.gsub(/\r\n|\r|\n|\s|\t/, "")
  tax_excluded = latest_data.search("td")[3].text.gsub(/\r\n|\r|\n|\s|\t/, "")
  tax = latest_data.search("td")[4].text.gsub(/\r\n|\r|\n|\s|\t/, "")

  CSV.open("data.csv", "w") do |csv|
    csv << ["日付", "確定件数", "確定報酬額・税込", "確定報酬額・税別", "確定報酬額・税金"]
    csv << [date, confirmed_count, tax_included, tax_excluded, tax]
  end
end
