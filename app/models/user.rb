class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :password, confirmation: true
  has_many :checks


  def send_reset_password_instructions(generate_token_only = false)
    token = set_reset_password_token
    send_reset_password_instructions_notification(token) unless generate_token_only

    token
  end

  def send_on_create_confirmation_instructions
    # Nope, i'll send this manually
  end

  def send_confirmation_instructions(temporary_password, reset_password_token)
    unless @raw_confirmation_token
      generate_confirmation_token!
    end

    opts = pending_reconfirmation? ? { to: unconfirmed_email } : { }
    opts[:temporary_password] = temporary_password
    opts[:reset_password_token] = reset_password_token
    send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
  end
end
