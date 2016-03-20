class Check < ActiveRecord::Base
  enum context: [ :checkin, :checkout, :delayed, :early ]
  belongs_to :user
  scope :for_today, -> { where(["created_at > ?", Time.current.in_time_zone.beginning_of_day]) }
  before_validation :set_check_context, on: :create

  include TimeRules

  def set_check_context
    if user.has_checked_in_today?
      if !user.has_checked_out_today?
        self.context = is_checkout_time? ? :checkout : :early
      end
    elsif
      self.context = is_checkin_time? ? :checkin : :delayed
    end

    errors[:base] << "Invalid check" if self.context.nil?
  end

  def self.values_for(*enum_labels)
    # For some reason, enum values parsing is not working,
    # so I'm implementing this myself
    contexts.values_at(*enum_labels)
  end
end
