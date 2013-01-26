require 'spec_helper'

describe AutoScheduler do
  let(:user) { create(:user) }
  let(:festival) { create(:festival, :with_films_and_screenings,
                          starts_on: Date.tomorrow, press: true) }
  let(:now) { Time.current }
  let(:autoscheduler) {
    # puts "creating AS"
    AutoScheduler.new(festival: festival, user: user,
                      show_press: false, now: now) }
  let(:expected_visible_screenings) { festival.screenings_visible_to(user) }

  context "when initializing" do
    subject { autoscheduler }

    it 'loads the user\'s picks' do
      subject.current_picks.should eq(festival.picks_for(user))
    end
    it 'loads the user-visible screenings' do
      subject.all_screenings.should eq(expected_visible_screenings)
    end
    it 'makes a map of screenings to id' do
      subject.all_screenings_by_id.should eq(expected_visible_screenings.map_by(:id))
    end
    it 'determines screening conflicts' do
      got_conflicts = subject.all_conflicting_screening_ids_by_screening_id
      got_conflicts.count.should eq(expected_visible_screenings.count)
      festival.screenings.each do |screening|
        conflicts = festival.screenings.map do |s|
          s.id if s.conflicts_with?(screening)
        end.compact
        got_conflicts[screening.id].should eq(conflicts)
      end
    end
    it 'keeps a list of pickable screenings' do
      subject.current_pickable_screenings.should eq(subject.all_screenings)
    end
  end

  context "when running" do
    subject { autoscheduler }

    it "starts by unselecting old screenings" do
      subject.stub(:next_best_screening).and_return(nil)
      festival.expects(:reset_screenings).once
      subject.run
    end

    it 'picks screenings until there are no more to pick' do
      subject.stub(:next_best_screening).and_return(:something, :something, nil)
      subject.expects(:schedule).twice
      subject.run
    end
  end

  context "when determining what to schedule" do
    it "updates all costs and finds the cheapest screening" do
      autoscheduler.should_receive(:update_screening_cost)\
        .exactly(autoscheduler.all_screenings.count).times
      autoscheduler.should_receive(:find_cheapest_screening)
      autoscheduler.next_best_screening
    end

    it "updates the cost of a screening" do
      screening = mock
      cost = mock
      costs = mock
      costs.should_receive(:[]).with(screening).and_return(cost)
      cost.should_receive(:update)
      autoscheduler.stub(:costs).and_return(costs)
      autoscheduler.update_screening_cost(screening)
    end

    context "and finding the cheapest screening" do
      it "returns the cheapest one if it's pickable" do
        screening = mock
        cost = mock(:pickable? => true, :screening => screening)
        autoscheduler.stub(:find_minimum_cost).and_return(cost)
        autoscheduler.find_cheapest_screening.should == screening
      end

      it "returns nil if there aren't any" do
        autoscheduler.stub(:find_minimum_cost).and_return(nil)
        autoscheduler.find_cheapest_screening.should be_nil
      end

      it "returns nil if the cheapest one isn't pickable" do
        cost = mock(:pickable? => false)
        autoscheduler.stub(:find_minimum_cost).and_return(cost)
        autoscheduler.find_cheapest_screening.should be_nil
      end
    end
  end

  context "when scheduling" do
    let(:screening) do
      festival.screenings.where(press: false).find do |s|
        festival.conflicting_screenings(s).present?
      end.tap do |x|
        # puts "existing screening is #{x.id} for film #{x.film_id}"
      end
    end
    let!(:existing_pick) do
      create(:pick, user: user, festival: festival, film: screening.film,
             screening: screening)
    end

    context "a conflicting screening" do
      let(:screening2) { festival.conflicting_screenings(screening)\
                                 .find {|s| !s.press } }
      let!(:conflicting_pick) do
        # puts "creating conflicting_pick on screening2"
        create(:pick, user: user, festival: festival, film: screening2.film)
      end
      subject {
        autoscheduler.schedule(screening2)
      }
      it "should raise" do
        expect { subject }.to raise_error(AutoScheduler::InternalError)
      end
    end

    context "a non-conflicting screening" do
      let(:screening2) do
        festival.screenings\
                .where('press = ? and film_id <> ? and id not in (?)',
                       false,
                       screening.film_id,
                       festival.conflicting_screenings(screening).map(&:id))\
                .first.tap do |result|
          fail unless result
        end.tap do |x|
          # puts "screening2 is #{x.id} for film #{x.film_id}"
        end
      end
      let!(:nonconflicting_pick) do
        # puts "creating nonconflicting pick"
        create(:pick, user: user, festival: festival, film: screening2.film)
      end
      subject {
        # puts "calling schedule, screening2"
        autoscheduler.schedule(screening2)
      }

      it { should_not raise_error(AutoScheduler::InternalError) }

      it "should update the current_ lists" do
        # puts "starting test"
        autoscheduler.current_picks_by_screening_id.should_not have_key(screening2.id)
        autoscheduler.current_picks_by_film_id.should have_key(nonconflicting_pick.film_id)
        autoscheduler.current_picks_by_film_id[nonconflicting_pick.film_id].should == nonconflicting_pick
        autoscheduler.current_pickable_screenings.should include(screening2)
        subject
        nonconflicting_pick.reload.screening_id.should_not be_nil
        autoscheduler.current_picks.should include(nonconflicting_pick)
        autoscheduler.current_picks_by_screening_id.should have_key(screening2.id)
        autoscheduler.current_pickable_screenings.should_not include(screening2)
      end
    end
  end
end
