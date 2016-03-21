module TimeRules
  CHECKIN_LIMIT_TIME = 9.25  # 9:15 am
  CHECKOUT_FROM_TIME = 18    # 6:00 pm
  REVIEW_DAY = 21 # 21th of each month

  def current_time
    base_time = self.created_at || Time.current.in_time_zone
    base_time.seconds_since_midnight/3600
  end

  def is_checkin_time?
    current_time <= CHECKIN_LIMIT_TIME
  end

  def is_checkout_time?
    current_time >= CHECKOUT_FROM_TIME
  end
end
