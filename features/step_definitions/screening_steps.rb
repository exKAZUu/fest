When /^I visit the film page$/ do
  visit admin_film_path(@film)
end

Then /^I should see the screenings listed$/ do
  rows = page.all("table#screenings tr.screening")
  rows.should have_at_least(2).items
  @film.screenings.zip(rows).each do |screening, row|
    row.find("td:first-child a")["href"].should eq(edit_admin_screening_path(screening))
  end
end
