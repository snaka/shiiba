require 'qiita'
client = Qiita::Client.new(access_token: ENV['QIITA_API_ACCESS_TOKEN'])

user_response = client.get_authenticated_user

page = 1

begin
  items_response = client.list_user_items(user_response.body["id"], page: page)
  puts "--- page: #{page} -------------------------------------"
  items_response.body.each do |item|
    date = Date.parse(item["created_at"])
    puts "#{date.strftime("%Y/%m/%d")} #{item["title"]}"
  end
  page += 1
  sleep 1
end while items_response.next_page_url

