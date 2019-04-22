require "mechanize"
require "csv"
require "line_notify"
require "pry"
require "active_support"
require "active_support/dependencies"

ActiveSupport::Dependencies.autoload_paths << "./lib"

# Settings
security = YAML.load_file("security.yml")
LINE_TOKEN = YAML.load_file("line_notify.yml")["token"]
affiliates = security.keys.select { |asp| security[asp]["id"] }

# Prepare csv template
CSV.open("data.csv", "w") do |csv|
  csv << ["アフィリエイトサイト", "本日発生件数", "本日発生報酬", "本日承認件数", "本日承認報酬", "当月発生件数", "当月発生報酬", "当月承認件数", "当月承認報酬"]
end

affiliates.each do |asp|
  login_id = security[asp]["id"]
  password = security[asp]["password"]

  puts "#{asp} のデータ検索を開始します。"

  case asp
  when "a8"
    client = AspScraper::Asp::A8.new(id: login_id, password: password)
    results = client.search
  when "felmat"
    client = AspScraper::Asp::Felmat.new(id: login_id, password: password)
    results = client.search
  when "access_trade"
    client = AspScraper::Asp::AccessTrade.new(id: login_id, password: password)
    results = client.search
  when "mosimo"
    client = AspScraper::Asp::Mosimo.new(id: login_id, password: password)
    results = client.search
  when "rentracks"
    client = AspScraper::Asp::Rentracks.new(id: login_id, password: password)
    results = client.search
  else
    raise "Incompatible ASP!"
  end

  puts "#{asp} のデータ検索を終了しました。"

  if results.present?
    results.unshift(asp)
    CSV.open("data.csv", "a") do |csv|
      csv << results
    end
  end

  unless LINE_TOKEN.nil?
    @notifies ||= "本日の発生報酬\n"
    @notifies << "#{affiliate.camelize}: ¥#{@ud_reward}\n"
  end
end

unless LINE_TOKEN.nil?
  line_notify = LineNotify.new(LINE_TOKEN)
  options = { message: @notifies }
  line_notify.send(options)
end

puts "すべての出力が完了しました！ data.csv をご確認ください！"
