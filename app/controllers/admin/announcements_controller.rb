module Admin
  class AnnouncementsController < ApplicationController
    before_filter :authenticate_admin!
    respond_to :html

    # GET /admin/announcements/new
    def new
      respond_with(:admin, @announcement = Announcement.new)
    end

    # GET /admin/announcements/1/edit
    def edit
      respond_with(:admin, @announcement = Announcement.find(params[:id]))
    end

    # POST /admin/announcements
    def create
      @announcement = Announcement.new(params[:announcement])
      if @announcement.save
        flash[:notice] = 'Announcement was successfully created.'
      end
      respond_with(:admin, @announcement, location: announcements_path)
    end

    # PUT /admin/announcements/1
    def update
      @announcement = Announcement.find(params[:id])
      if @announcement.update_attributes(params[:announcement])
        flash[:notice] = 'Announcement was successfully updated.'
      end
      respond_with(:admin, @announcement, location: announcements_path)
    end

    # DELETE /admin/announcements/1
    def destroy
      @announcement = Announcement.find(params[:id])
      @announcement.destroy
      respond_with(:admin, @announcement, location: announcements_path)
    end
  end
end
