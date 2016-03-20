class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:check]
  before_action :require_admin, except: [:dashboard, :check]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  respond_to :json, only: [:check]

  def dashboard
  end

  def check
    @user = User.find_by(barcode: params[:barcode])

    if @user
      new_check = @user.checks.new

      if new_check.save
        render json_with_status :created and return
      else
        render json_with_status(:unprocessable_entity, new_check.errors.full_messages.first) and return
      end
    end

    render json_with_status :unprocessable_entity, "User not found"
  end

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    generated_password = Devise.friendly_token.first(8)

    @user.password = @user.password_confirmation = generated_password

    respond_to do |format|
      if @user.save
        reset_password_token = @user.send_reset_password_instructions(true)
        @user.send_confirmation_instructions(generated_password, reset_password_token)
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update_without_password(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def require_admin
      redirect_to :dashboard, notice: "Forbidden" unless current_user.admin?
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :date_of_birth, :admin)
    end
end
