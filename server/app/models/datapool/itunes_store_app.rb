# == Schema Information
#
# Table name: datapool_store_products
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  publisher_name :string(255)
#  product_id     :string(255)      not null
#  title          :string(255)      not null
#  description    :text(65535)
#  url            :string(255)      not null
#  icon_url       :string(255)
#  review_count   :integer          default(0), not null
#  average_score  :float(24)        default(0.0), not null
#  published_at   :datetime
#  options        :text(65535)
#
# Indexes
#
#  store_product_published_at_index  (published_at)
#  store_product_unique_index        (product_id,type) UNIQUE
#  store_product_url_index           (url)
#

class Datapool::ItunesStoreApp < Datapool::StoreProduct
  URLS_HASH = {
    top_grossing: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/top-grossing/all/300/explicit.json",
    top_free: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/top-free/all/300/explicit.json",
    top_paid: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/top-paid/all/300/explicit.json",
    new_games: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/new-games-we-love/all/300/explicit.json",
    new_apps: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/new-apps-we-love/all/300/explicit.json",
    top_grossing_tablet: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/top-grossing-ipad//all/300/explicit.json",
    top_free_tablet: "https://rss.itunes.apple.com/api/v1/jp/top-free-ipad/top-free/all/300/explicit.json",
    top_free_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-free-mac-apps/all/200/explicit.json",
    top_grossing_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-grossing-mac-apps/all/200/explicit.json",
    top_all_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-mac-apps/all/200/explicit.json",
    top_paid_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-paid-mac-apps/all/200/explicit.json",
  }

  def self.update_rankings!
    h = []
    URLS_HASH.each do |category, crawl_url|
      hash = ApplicationRecord.request_and_parse_json(crawl_url)
      h << hash
    end
    p h
  end

  def self.import_review!
  end
end