require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  describe "index" do
    it "returns a JSON array" do
      get movies_url
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Array
    end

    it "should return many movie fields" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.each do |movie|
        movie.must_include "title"
        movie.must_include "release_date"
      end
    end

    it "returns all movies when no query params are given" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.length.must_equal Movie.count

      expected_names = {}
      Movie.all.each do |movie|
        expected_names[movie["title"]] = false
      end

      data.each do |movie|
        expected_names[movie["title"]].must_equal false, "Got back duplicate movie #{movie["title"]}"
        expected_names[movie["title"]] = true
      end
    end
  end

  describe "show" do
    it "Returns a JSON object" do
      get movie_url(title: movies(:one).title)
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Hash
    end

    it "Returns expected fields" do
      get movie_url(title: movies(:one).title)
      assert_response :success

      movie = JSON.parse @response.body
      movie.must_include "title"
      movie.must_include "overview"
      movie.must_include "release_date"
      movie.must_include "inventory"
      movie.must_include "available_inventory"
    end

    it "Returns an error when the movie doesn't exist" do
      get movie_url(title: "does_not_exist")
      assert_response :not_found

      data = JSON.parse @response.body
      data.must_include "errors"
      data["errors"].must_include "title"

    end
  end

  describe "create" do 
    let(:movie_params) {
      { 
        title: "Parasite",
        overview: "test!",
        inventory: 10,
        image_url: "image test",
        external_id: 123976
      }
    }

    it "creates a movie with valid data" do 
      count = Movie.count 

      expect {
        post movies_path, params: movie_params
      }.must_differ "Movie.count", 1

      expect(Movie.count).must_equal count + 1

      must_respond_with :created
    end

    it "will respond with bad_request for invalid data" do 
      movie_params[:title] = nil

      expect {
        post movies_path, params: movie_params
      }.wont_change "Movie.count"
      
      must_respond_with :bad_request
  
      expect(response.header['Content-Type']).must_include 'json'
      body = JSON.parse(response.body)
      
      expect(body["errors"].keys).must_include "title"
    end


    it "cannot add the same movie twice" do 
      count = Movie.count 

      post movies_path, params: movie_params

      expect {
        post movies_path, params: movie_params
      }.wont_differ "Movie.count"

      expect(Movie.count).must_equal count + 1

      must_respond_with :forbidden
      expect(body).must_include "This movie is already in the database"
    end
  end
end
