class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query] # maybe the user search input?
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  # runs require_movie before this action
  def show
    # if movie exists, status: ok and return movie info
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
      )
  end


  def create 
    movie = Movie.new(movie_params)

    # if movie is already in db, don't add
    if Movie.find_by(external_id: movie.external_id)
      render json: {
        errors: "This movie is already in the database"
      }, status: :forbidden
      return
    end

    if movie.save
      # render json: movie.as_json(only: [:id, :title, :overview, :release_date, :image_url, :external_id]), status: :created
      # return
      render json: movie.as_json(only: [:id]), status: :created
      return

    else 
      render json: {
        errors: movie.errors.messages
      }, status: :bad_request

    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

  def movie_params 
    return params.permit(:title, :overview, :release_date, :image_url, :external_id, :inventory)
  end
end
