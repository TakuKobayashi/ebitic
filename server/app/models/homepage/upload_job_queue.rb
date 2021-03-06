# == Schema Information
#
# Table name: homepage_upload_job_queues
#
#  id                 :bigint(8)        not null, primary key
#  homepage_access_id :integer          not null
#  from_type          :string(255)      not null
#  token              :string(255)      not null
#  state              :integer          default("standby"), not null
#  upload_url         :string(255)
#  upload_file_size   :integer
#  options            :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  homepage_job_queue_created_at_index  (created_at)
#  homepage_job_queue_token_index       (token)
#  homepage_job_queue_user_index        (homepage_access_id,state)
#

class Homepage::UploadJobQueue < ApplicationRecord
  # {
  #   upload_info: {
  #     url:
  #     url_key:
  #     google_account_id:
  #   }
  # }
  #
  serialize :options, JSON

  enum state: {
    standby: 0,
    executing: 1,
    compressing: 2,
    uploading: 3,
    complete: 4,
    downloaded: 5,
    failed: 6,
    cleaned: 7,
  }

  belongs_to :visitor, class_name: 'Homepage::Access', foreign_key: :homepage_access_id, required: false

  def self.cleanup!
    Homepage::UploadJobQueue.find_each do |job|
      next if job.standby?
      next if job.complete? && job.updated_at > 7.day.ago
      next if (job.executing? || job.compressing? || job.uploading?) && job.updated_at > 8.hours.ago
      job.cleaned!
      if job.cleaned? && job.upload_url.present?
        s3 = Aws::S3::Client.new
        filepath = job.upload_url.gsub(Datapool::ResourceMetum::S3_ROOT_URL, "")
        s3.delete_object(bucket: "taptappun", key: filepath)
        job.update!(upload_url: nil, upload_file_size: nil)
      end
      if job.from_type == "Datapool::TwitterImageMetum" && job.options["twitter_skip"].present?
        if job.options.present? && job.options["params"].present? && job.options["params"]["search_type"].to_i == 0
          images = Datapool::TwitterImageMetum.search_image_tweet!(keyword: job.options["params"]["keyword"].to_s)
          job.options["twitter_skip"] = images.blank?
          job.save!
        end
      end
    end
  end

  def compress_resources_and_upload!(resources:)
    Tempfile.create(SecureRandom.hex) do |tempfile|
      self.compressing!
      zippath = ResourceUtility.download_and_compress_to_zip(zip_filepath: tempfile.path, resources: resources)
      if zippath.blank?
        self.failed!
        return false
      end
      self.uploading!
      upload_complessed_file!(zippath: zippath, resources: resources)
    end
  end

  def from_type_name
    if self.from_type == "Datapool::FrickrImageMetum"
      return I18n.t("activerecord.models.datapool_image_metum.flickr")
    elsif self.from_type == "Datapool::TwitterImageMetum"
      return I18n.t("activerecord.models.datapool_image_metum.twitter")
    elsif self.from_type == "Datapool::WebSiteImageMetum"
      return I18n.t("activerecord.models.datapool_image_metum.website")
    elsif self.from_type == "Datapool::GoogleImageSearch"
      return I18n.t("activerecord.models.datapool_image_metum.google_image_search")
    else
      return I18n.t("activerecord.models.datapool_image_metum.other")
    end
  end

  def upload_complessed_file!(zippath:, resources:)
    zipfile = File.open(zippath)
    zipfile_size = zipfile.size
    upload_info = options["upload_info"] || {}
    if upload_info["upload_info"].present?
      if upload_info["upload_info"]["google_account_id"]
        google_account = GoogleAccount.find_by(id: upload_info["upload_info"]["google_account_id"])
        if google_account.present?
          google_account.upload_to_drive(zipfile)
          self.update!(state: :complete, upload_file_size: zipfile_size)
          return true
        end
      elsif upload_info["upload_info"]["url"].present? && upload_info["upload_info"]["url_key"].present?
        RequestParser.request_and_response_body(url: upload_info["upload_info"]["url"], method: :post, body: {upload_info["upload_info"]["url_key"] => zipfile})
        self.update!(state: :complete, upload_url: upload_info["upload_info"]["url"], upload_file_size: zipfile_size)
        return true
      end
    end
    upload_resource_path = resources.group_by{|resource| resource.s3_path }.max_by{|path, resources| resources.size }.first
    if upload_resource_path.blank?
      self.failed!
      return false
    end
    #      upload_filepath = Rails.root.to_s + "/tmp/#{Time.current.strftime("%Y%m%d_%H%M%S%L")}.zip"
    #      FileUtils.cp(zippath, upload_filepath)
    upload_filepath = ResourceUtility.upload_s3(zipfile, upload_resource_path + "#{Time.current.strftime("%Y%m%d_%H%M%S%L")}.zip")
    self.update!(state: :complete, upload_url: Datapool::ResourceMetum::S3_ROOT_URL + upload_filepath, upload_file_size: zipfile_size)
    return true
  end
end
