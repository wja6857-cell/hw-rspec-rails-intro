class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(params, api_key = ENV['TMDB_API_KEY'])
    url = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{CGI.escape(params[:title])}"
    url += "&year=#{params[:release_year]}" if params[:release_year].present?
    url += "&language=#{params[:language]}" if params[:language] == 'en'
    response = Faraday.get(url)
    JSON.parse(response.body)['results'].map do |movie|
      Movie.new(title: movie['title'], rating: 'R', release_date: movie['release_date'], description: movie['overview'])
    end
  end
end
