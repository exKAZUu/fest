require 'spec_helper'

describe ScreeningsController do
  describe "GET 'show'" do
    it "assigns @screening, @festival, @film, and @other_screenings" do
      screening = create(:screening)
      get :show, {:id => screening.to_param}
      assigns(:screening).should eq(screening)
      assigns(:festival).should eq(screening.festival)
      assigns(:film).should eq(screening.film)
      assigns(:other_screenings).should eq(screening.film.screenings - [screening])
    end
  end
end
