class User < ActiveRecord::Base
  include HasBarcode
  BARCODE_SUFFIX_LENGTH = 6

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :first_name, :email
  validates :password, confirmation: true

  after_save :set_barcode, if: "barcode.nil?"

  has_many :checks
  has_barcode :get_barcode,
              :outputter => :svg,
              :type => :code_128,
              :value => Proc.new { |p| p.barcode }

  scope :employees, -> { where(admin: false) }

  def has_checked_at?(check_types, day = nil)
    checks.for_day(day).where(context: Check.values_for(*check_types)).any?
  end

  def has_checked_in_at?(day = nil)
    has_checked_at?([:checkin, :delayed], day)
  end

  def has_checked_out_at?(day = nil)
    has_checked_at?([:checkout, :early], day)
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

  private

  def set_barcode
    new_barcode = "%06d%0#{BARCODE_SUFFIX_LENGTH}d" % [id, rand(10**BARCODE_SUFFIX_LENGTH)]
    update_column(:barcode, new_barcode)
  end

end
