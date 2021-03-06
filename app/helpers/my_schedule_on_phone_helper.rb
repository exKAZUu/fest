module MyScheduleOnPhoneHelper
  def my_schedule_on_phone?
    (user_signed_in? && current_user.has_screenings_for?(@festival)) ? true : nil
  end

  def my_schedule_visible_on_phone
    my_schedule_on_phone? && ' visible-phone'
  end

  def my_schedule_hidden_on_phone
    my_schedule_on_phone? && ' hidden-phone'
  end
end
