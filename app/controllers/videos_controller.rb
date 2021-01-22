class VideosController < ApplicationController
  before_action :require_video, only: [:show]

  def index
    if params[:query]
      data = VideoWrapper.search(params[:query])
    else
      data = Video.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @video.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
      )
  end

  def create
    video = Video.new(video_params)
    if Video.find_by(external_id: params[:external_id]).nil?
      if video.save
        render json: video.as_json(only: [:id]), status: :created
        return
      else
        render json: { errors: video.errors.messages }, status: :bad_request
        return
      end
    end
    # this is where we stopped - how do we create a video based on search results
    # video = Video.new(params)
    # do we need to create a starting inventory or is it just one??  yes, no, maybe ... functional reqs contradict readMe/
    # instructions mention how to handle if a video has already been added ->
    # I think we account for this with the external id -- if a video exists with the same ext. id then don't create
    # else, we do video.save
    # video = VideoWrapper.search(params)
    # ap "#{video.title} Added to the library!"
  end

  private

  def video_params
    return params.permit(:title, :overview, :release_date, :image_url, :external_id, )
  end

  def require_video
    @video = Video.find_by(title: params[:title])
    unless @video
      render status: :not_found, json: { errors: { title: ["No video with title #{params["title"]}"] } }
    end
  end
end
