class MovieWrapper
  BASE_URL = "https://api.themoviedb.org/3/"
  KEY = ENV["MOVIEDB_KEY"]

  BASE_IMG_URL = "https://image.tmdb.org/t/p/"
  DEFAULT_IMG_SIZE = "w185"
  # DEFAULT_IMG_URL = "http://lorempixel.com/185/278/"
  DEFAULT_IMG_URL = "https://i.imgur.com/Uw59wWE.png?1"
  

  def self.search(query, retries_left=3)
    raise ArgumentError.new("Can't search without a MOVIEDB_KEY.  Please check your .env file!") unless KEY

    url = BASE_URL + "search/movie?api_key=" + KEY + "&query=" + query

    response =  HTTParty.get(url) # MovieDB API call

    if response.success?
      # if no results, return empty array
      if response["total_results"] == 0
        return []
      # if results, create new Movie for each result
      else
        movies = response["results"].map do |result|
          self.construct_movie(result)
        end
        return movies
      end
    elsif retries_left > 0
      sleep(1.0 / (2 ** retries_left))

      return self.search(query, retries_left - 1) # recursively call search while there are more than 0 retries_left
    else
      raise "Request failed: #{url}"
    end
  end

  private

  def self.construct_movie(api_result)
    Movie.new(
      title: api_result["title"],
      overview: api_result["overview"],
      release_date: api_result["release_date"],
      image_url: self.construct_image_url(api_result["poster_path"]),
      external_id: api_result["id"]
    )
  end

  def self.construct_image_url(img_name)
    if img_name.nil?
      return nil
    else
      return BASE_IMG_URL + DEFAULT_IMG_SIZE + img_name
    end
  end
end
