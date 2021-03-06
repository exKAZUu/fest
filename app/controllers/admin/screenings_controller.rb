module Admin
  class ScreeningsController < ApplicationController
    before_filter :authenticate_admin!
    before_filter :load_film_and_festival, only: [:index, :new, :create]
    before_filter :load_screening_film_and_festival, except: [:index, :new, :create]
    before_filter :load_venues_for_select, only: [:new, :edit]
    before_filter :load_attendees, only: [:edit, :update]
    respond_to :html

    # GET /admin/screenings/1
    def show
      respond_with(:admin, @screening)
    end

    # GET /admin/films/1/screenings/new
    def new
      venue_id = @festival.venues.find_by_id(params[:venue_id]).to_param \
        if params[:venue_id]
      starts_at = params[:starts_at] || @festival.starts_on.beginning_of_day
      @screening = @film.screenings.build(festival: @festival,
                                          venue_id: venue_id,
                                          starts_at: starts_at)
      respond_with(:admin, @screening)
    end

    # GET /admin/screenings/1/edit
    def edit
      respond_with(:admin, @screening)
    end

    # POST /admin/films/1/screenings
    def create
      @screening = @film.screenings.build(params[:screening])
      location = if @screening.save
        flash[:notice] = "#{l @screening.starts_at, format: :dmd_hm} screening of '#{@film.name}' at #{@screening.venue.name} was successfully created."
        new_admin_film_screening_path(@film,
                                      venue_id: @screening.venue_id,
                                      starts_at: @screening.starts_at)
      else
        admin_film_path(@film)
      end
      respond_with(:admin, @screening, location: location)
    end

    # PUT /admin/screenings/1
    def update
      if @screening.update_attributes(params[:screening])
        emails = @users.map {|u| u.email }
        message = "#{pluralize(emails.count, 'user')} were affected"
        message += ': ' + emails.join(', ') if emails.present?
        flash[:notice] = "Screening was successfully updated; #{message}."
      end
      respond_with(:admin, @screening, location: admin_film_path(@film))
    end

    # DELETE /admin/screenings/1
    def destroy
      @screening.destroy
      flash[:notice] = 'Screening was successfully destroyed.'
      respond_with(:admin, @screening, location: admin_film_path(@film))
    end

    protected
    def load_film_and_festival
      @film = Film.includes(:festival).find(params[:film_id])
      @festival = @film.festival
    end

    def load_screening_film_and_festival
      @screening = Screening.includes(film: :festival).find(params[:id])
      @film = @screening.film
      @festival = @film.festival
    end

    def load_venues_for_select
      @venues = @festival.venues.sort_by(&:name)
    end

    def load_attendees
      @picks = @screening.picks.includes(:user)
      @users = @picks.map {|p| p.user }
    end
  end
end
