module Admin
  class FilmsController < ApplicationController
    before_filter :authenticate_admin!
    before_filter :load_festival, only: [:index, :new, :create]
    respond_to :html
    layout 'festivals_admin'

    # GET /admin/festivals/1/films
    def index
      respond_with(@films = @festival.films.includes(:screenings).order(:sort_name).all)
    end

    # GET /admin/films/1
    def show
      @film = Film.includes(:festival, screenings: :venue).find(params[:id])
      @festival = @film.festival
      respond_with(:admin, @film)
    end

    # GET /admin/festivals/1/films/new
    def new
      respond_with(:admin, @film = @festival.films.build)
    end

    # GET /admin/films/1/edit
    def edit
      @film = Film.includes(:festival).find(params[:id])
      @festival = @film.festival
      respond_with(:admin, @film)
    end

    # POST /admin/festivals/1/films
    def create
      @film = @festival.films.build(params[:film])
      location = if @film.save
        flash[:notice] = "Film '#{@film.name}' was successfully created."
        new_admin_film_screening_path(@film)
      else
        admin_festival_films_path(@festival)
      end
      respond_with(:admin, @film, location: location)
    end

    # PUT /admin/films/1
    def update
      @film = Film.includes(:festival).find(params[:id])
      @festival = @film.festival
      if @film.update_attributes(params[:film])
        flash[:notice] = 'Film was successfully updated.'
      end
      respond_with(:admin, @film, location: admin_festival_films_path(@festival))
    end

    # DELETE /admin/films/1
    def destroy
      @film = Film.find(params[:id])
      @film.destroy
      flash[:notice] = 'Film was successfully destroyed.'
      respond_with(:admin, @film, location: admin_festival_films_path(@film.festival))
    end
  end
end
