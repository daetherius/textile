module TimeRules
  CHECKIN_LIMIT_TIME = 9.25  # 9:15 am
  CHECKOUT_FROM_TIME = 18    # 6:00 pm

  def current_time
    Time.current.in_time_zone.seconds_since_midnight/3600
  end

  def is_checkin_time?
    current_time <= CHECKIN_LIMIT_TIME
  end

  def is_checkout_time?
    current_time >= CHECKOUT_FROM_TIME
  end
end
