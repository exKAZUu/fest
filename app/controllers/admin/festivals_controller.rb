module Admin
  class FestivalsController < ApplicationController
    before_filter :authenticate_admin!
    layout 'festivals_admin'
    respond_to :html

    # GET /admin/festivals/new
    def new
      respond_with(:admin, @festival = Festival.new(revised_at: Time.current))
    end

    # GET /admin/festivals/1/edit
    def edit
      respond_with(:admin, @festival = Festival.find_by_slug!(params[:id]))
    end

    # POST /admin/festivals
    def create
      @festival = Festival.new(params[:festival])
      flash[:notice] = 'Festival was successfully created.' if @festival.save
      respond_with(:admin, @festival, location: festivals_path)
    end

    # PUT /admin/festivals/1
    def update
      @festival = Festival.find_by_slug!(params[:id])
      if @festival.update_attributes(params[:festival])
        flash[:notice] = 'Festival was successfully updated.'
      end
      respond_with(:admin, @festival, location: festival_path(@festival))
    end

    # DELETE /admin/festivals/1
    def destroy
      @festival = Festival.find_by_slug!(params[:id])
      @festival.destroy
      flash[:notice] = 'Festival was successfully destroyed.'
      respond_with(:admin, @festival, location: festivals_path)
    end
  end
end
