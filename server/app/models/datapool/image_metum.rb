# == Schema Information
#
# Table name: datapool_image_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  title             :string(255)      not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  query             :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_image_meta_on_origin_src  (origin_src)
#  index_datapool_image_meta_on_title       (title)
#

class Datapool::ImageMetum < ApplicationRecord
  serialize :options, JSON

  IMAGE_FILE_EXTENSIONS = [
    ".agp",
    ".ai", #Illustrator
    ".cdr",
    ".cpc", ".cpi",
    ".eps",
    ".eri",
    ".gif", #GIF
    ".iff", ".ilbm", ".lbm",
    ".ima",
    ".jpg", ".jpeg", #JPEG
    ".jxr", ".hdp", ".wdp",
    ".jp2", ".j2c",
    ".mki",
    ".mag",
    ".pi",
    ".pict", ".pic", ".pct",
    ".pdf", #PDF
    ".png", #PNG
    ".psd", ".psb", ".pdd", #PSD
    ".psp",
    ".svg", #SVG
    ".tga", ".tpic", #TGA 3Dモデルのテクスチャーとかによく使われる
    ".tif", #tif 文字とかフォントとか
    ".webp",
    ".bmp", #BMP
  ]

  CRAWL_IMAGE_ROOT_PATH = "project/crawler/images/"

  def src
    url = Addressable::URI.parse(self.origin_src)
    url.query = self.query
    return url.to_s
  end

  def src=(url)
    aurl = Addressable::URI.parse(url)
    self.origin_src = aurl.origin.to_s + aurl.path.to_s
    self.query = aurl.query
  end

  def self.match_image_filename(filepath)
    paths = filepath.split("/")
    imagefile_name = paths.detect{|p| IMAGE_FILE_EXTENSIONS.any?{|ie| p.include?(ie)} }
    return "" if imagefile_name.blank?
    ext = IMAGE_FILE_EXTENSIONS.detect{|ie| imagefile_name.include?(ie) }
    return imagefile_name.match(/(.+?#{ext})/).to_s
  end

  def self.s3_file_image_root
    return CRAWL_IMAGE_ROOT_PATH
  end

  def save_filename
    if self.original_filename.present?
      return self.original_filename
    end
    return SecureRandom.hex
  end

  def download_image_response
    aurl = Addressable::URI.parse(self.src)
    client = HTTPClient.new
    response = client.get(aurl.to_s)
    return response
  end

  def self.upload_s3(binary, filename)
    s3 = Aws::S3::Client.new
    filepath = self.s3_file_image_root + filename
    s3.put_object(bucket: "taptappun",body: binary, key: filepath, acl: "public-read")
    return filepath
  end

  def convert_to_base64
    filepath = self.src
    ext = File.extname(filepath)
    s3 = Aws::S3::Client.new
    binary = s3.get_object(bucket: "taptappun",key: filepath)
    base64_image = Base64.strict_encode64(binary.body.read)
    return "data:image/" + ext[1..ext.size] + ";base64," + base64_image
  end

  def self.constract(image_url:, title:, check_image_file: false, options: {})
    aimage_url = Addressable::URI.parse(image_url.to_s)
    image_type = nil
    if check_image_file
      # 画像じゃないものも含まれていることもあるので分別する
      image_type = FastImage.type(aimage_url.to_s)
      return nil if image_type.blank?
    end
    image = self.new(title: title.to_s, options: options)
    if aimage_url.scheme == "data"
      image_binary =  Base64.decode64(aimage_url.to_s.gsub(/data:image\/.+;base64\,/, ""))
      new_filename = SecureRandom.hex + ".#{image_type.to_s.downcase}"
      uploaded_path = self.upload_s3(image_binary, new_filename)
      image.src = ApplicationRecord::S3_ROOT_URL + uploaded_path
    else
      image.src = aimage_url.to_s
    end
    image.original_filename = self.match_image_filename(image.src.to_s)
    return image
  end
end
