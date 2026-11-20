require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end
    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with(hash_including(title: 'hardware')).
        and_return(@fake_results)
      get :search_tmdb, params: { title: 'hardware' }
    end
    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, params: { title: 'hardware' }
      end
      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end
      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end
    it 'shows an error when the title is blank' do
      expect(Movie).not_to receive(:find_in_tmdb)
      get :search_tmdb, params: { title: '' }
      expect(flash[:danger]).to eq('Please fill in all required fields!')
    end
    it 'shows an error when no movies are found' do
      allow(Movie).to receive(:find_in_tmdb).and_return([])
      get :search_tmdb, params: { title: 'hardware' }
      expect(flash[:danger]).to eq('No movies found with given parameters!')
    end
  end

  describe 'adding a movie' do
    before :each do
      post :add_movie, params: { title: 'Hackers', rating: 'R', release_date: '1995-09-15', description: 'Hackers.' }
    end
    it 'saves the movie to the database' do
      expect(Movie.find_by(title: 'Hackers')).not_to be_nil
    end
    it 'redirects to the search page with a success message' do
      expect(response).to redirect_to(search_path)
      expect(flash[:success]).to eq('Hackers was successfully added to RottenPotatoes.')
    end
  end
end
