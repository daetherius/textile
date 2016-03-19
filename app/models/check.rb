class Check < ActiveRecord::Base
  include TimeRules

  belongs_to :user
  enum context: [ :checkin, :checkout ]

  scope :for_today, -> { where(["created_at > ?", Time.current.in_time_zone.beginning_of_day]) }

  before_validation :set_check_context, on: :create

  def set_check_context
    if !user.has_checked_today? && is_checkin_time?
      self.context = :checkin
    elsif user.has_checked_today? && is_checkout_time?
      self.context = :checkout
    else
      errors[:base] << "Invalid check"
    end
  end
end
