# == Schema Information
#
# Table name: datapool_websites
#
#  id         :bigint(8)        not null, primary key
#  type       :string(255)
#  title      :string(255)      not null
#  origin_src :string(255)      not null
#  other_src  :text(65535)
#  options    :text(65535)
#
# Indexes
#
#  index_datapool_websites_on_origin_src  (origin_src)
#  index_datapool_websites_on_title       (title)
#

class Datapool::Website < Datapool::ResourceMetum
  serialize :options, JSON

  def self.new_website(url:, title: "", options: {})
    website = self.new(
      title: title,
      options: {
      }.merge(options)
    )
    website.src = url
    return website
  end

  def self.resource_crawl!
    Datapool::Website.find_each do |website|
      next if website.options["image_crawled_at"].present?
      begin
        Datapool::WebSiteImageMetum.crawl_images!(url: website.src)
        site = RequestParser.request_and_parse_html(url: website.src, options: {:follow_redirect => true})
        if site.title.present?
          website.title = Sanitizer.basic_sanitize(site.title.to_s).truncate(255)
        end
      rescue => e
        website.write_crawl_error_log(e)
      ensure
        website.options["image_crawled_at"] = Time.current
        website.save!
      end
    end
  end

  def write_crawl_error_log(error)
    File.open("#{Rails.root}/log/website_crawl_error.log", 'a') do |file|
      file.write (["ID:#{self.id} URL:#{self.src} website is crawl error!!!!", error.message] + error.backtrace).join("\n") + "\n\n"
    end
  end
end
