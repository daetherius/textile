class Check < ActiveRecord::Base
  enum context: [ :checkin, :checkout, :delayed, :early ]
  belongs_to :user
  before_validation :set_check_context, on: :create

  include TimeRules

  def set_check_context
    if user.has_checked_in_at?(self.created_at)
      if !user.has_checked_out_at?(self.created_at)
        self.context = is_checkout_time? ? :checkout : :early
      end
    else
      self.context = is_checkin_time? ? :checkin : :delayed
    end

    errors[:base] << "Invalid check" if self.context.nil?
  end

  def self.for_day(day = Time.current.in_time_zone)
   where(created_at: day.beginning_of_day..day.end_of_day)
 end

  def self.values_for(*enum_labels)
    # For some reason, enum values parsing is not working,
    # so I'm implementing this myself
    contexts.values_at(*enum_labels)
  end
end
