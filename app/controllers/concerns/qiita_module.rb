module QiitaModule
  extend ActiveSupport::Concern

  def get_qiita_items(user_id)
    qiita = Qiita::Client.new(access_token: Rails.configuration.qiita["access_token"])

    page = 1
    item_dates = {}
    a_year_ago = 1.years.ago
    filled = false

    begin
      Rails.logger.debug "--- Qiita::list_user_items user: #{user_id}, page: #{page} ---"
      items_response = qiita.list_user_items(
        user_id,
        page: page,
        per_page: 100
      )
      items_response.body.each do |item|
        date = Date.parse(item["created_at"])
        break if filled = date < a_year_ago
        item_dates[date] = item_dates.fetch(date, 0) + 1
      end
      break if filled
      page += 1
      sleep 1
    end while items_response.next_page_url

    item_dates
  end
end
