class Check < ActiveRecord::Base
  belongs_to :user
  enum context: [ :checkin, :checkout ]

  scope :for_today, -> { where(["created_at > ?", Time.current.utc.beginning_of_day]) }

end
