class Homepage::Tools::ImageCrawlController < Homepage::BaseController

  before_action :load_upload_jobs, only: :index
  before_action :execute_upload_job, only: [:url_crawl, :twitter_crawl, :flickr_crawl, :google_image_search_crawl, :niconico_crawl, :getty_images_crawl]

  def index
  end

  def twitter
  end

  def twitter_crawl
    redirect_to tools_image_crawl_url
  end

  def flickr
  end

  def flickr_crawl
    redirect_to tools_image_crawl_url
  end

  def url
  end

  def url_crawl
    redirect_to tools_image_crawl_url
  end

  def google_image_search
  end

  def google_image_search_crawl
    redirect_to tools_image_crawl_url
  end

  def niconico
  end

  def niconico_crawl
    redirect_to tools_image_crawl_url
  end

  def getty_images

  end

  def getty_images_crawl
    redirect_to tools_image_crawl_url
  end

  def download_zip
    job = @visitor.upload_jobs.find_by(id: params[:job_id])
    job.downloaded!
    redirect_to job.upload_url
  end

  private
  def check_and_auth_google
    if @visitor.google.nil?
      session["redirect_url"] = tools_image_crawl_url
      session["user_id"] = @visitor.id
      session["user_type"] = @visitor.class.to_s
      redirect_to "/auth/google_oauth2" and return
    end
  end

  def load_upload_jobs
    if @visitor.blank?
      @upload_jobs = []
    else
      @upload_jobs = @visitor.upload_jobs.where.not(state: :cleaned).
        where(from_type: ["Datapool::FrickrImageMetum", "Datapool::TwitterImageMetum", "Datapool::WebSiteImageMetum", "Datapool::GoogleImageSearch"]).
        order("id DESC")
    end
  end

  def execute_upload_job
    if params[:action] == "flickr_crawl"
      prefix = "Datapool::FrickrImageMetum"
    elsif params[:action] == "twitter_crawl"
      prefix = "Datapool::TwitterImageMetum"
    elsif params[:action] == "url_crawl"
      prefix = "Datapool::WebSiteImageMetum"
    elsif params[:action] == "niconico_crawl"
      prefix = "Datapool::NiconicoImageMetum"
    elsif params[:action] == "getty_images_crawl"
      prefix = "Datapool::GettyImageMetum"
    else
      prefix = "Datapool::GoogleImageSearch"
    end
    @upload_job = @visitor.upload_jobs.find_or_initialize_by(token: params[:authenticity_token])
    @upload_job.from_type = prefix
    @upload_job.options ||= {params: params.to_h.dup}
    @upload_job.save!
    flash[:notice] = "処理を受け付けました。処理が完了するまでしばらくお待ち下さい。"
    ImageCrawlWorker.perform_async(params.to_h.dup, @upload_job.id)
  end
end