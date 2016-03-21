class User < ActiveRecord::Base
  include HasBarcode
  BARCODE_SUFFIX_LENGTH = 6

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :first_name, :email
  validates :password, confirmation: true
  has_many :checks
  after_save :set_barcode, if: "barcode.nil?"

  has_barcode :barcode,
              :outputter => :svg,
              :type => :code_128,
              :value => Proc.new { |p| p[:barcode].to_s }

  def has_checked_today?(*check_types)
    checks.for_today.where(context: Check.values_for(*check_types)).any?
  end

  def has_checked_in_today?
    has_checked_today?(:checkin, :delayed)
  end

  def has_checked_out_today?
    has_checked_today?(:checkout, :early)
  end

  def full_name
    first_name + (" #{last_name}" if last_name)
  end

  ## DeviseMailer overrides
    def send_reset_password_instructions(generate_token_only = false)
      token = set_reset_password_token
      send_reset_password_instructions_notification(token) unless generate_token_only

      token
    end

    def send_on_create_confirmation_instructions
      # Nope, i'll send this manually
    end

    def send_confirmation_instructions(temporary_password = false, reset_password_token = false)
      unless @raw_confirmation_token
        generate_confirmation_token!
      end

      opts = pending_reconfirmation? ? { to: unconfirmed_email } : { }
      opts[:temporary_password] = temporary_password
      opts[:reset_password_token] = reset_password_token
      send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
    end
end
