class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:check]
  before_action :require_admin, except: [:dashboard, :check]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action only: [:dashboard] do
    if current_user.admin?
      redirect_to(users_path)
    end
  end

  respond_to :json, only: [:check]

  def dashboard
    @user = current_user

    if is_review_day?
      now = Time.current.in_time_zone
      @period = (now.ago(2.weeks).to_date..now.to_date).to_a.reverse
      @checks = current_user.checks
    end

    render 'history'
  end

  def history
    @user = User.find(params[:user_id])

    if @user
      user_checks = @user.checks.order(created_at: :asc)
      user_checks = user_checks.where(context: Check.values_for(*params[:check_types])) if params[:check_types]

      now = Time.current.in_time_zone
      date_from = params[:date_from] || now.ago(2.months) # `false` or a default limit if needed, e.g. `now.ago(1.year)`
      date_until = params[:date_until] || now

      @checks = user_checks.where(created_at: date_from..date_until)
      @period = (date_from.to_date..date_until.to_date).to_a.reverse

    else
      redirect_to dashboard_path, alert: "No user found"
    end
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
    @query = {}

    if params["q"].present?
      @query = params["q"].reject{|k,v| v.blank? }

      if @query.present?
        if @query["barcode"]
          @users = @users.where(barcode: @query["barcode"])
        else
          # Having checks conditions
          if @query["with"] && @query["check_types"]
            filter_query = @users.joins(:checks).group("users.id") # Don't pollute original query

            # Date conditions with defaults to 1 Month in the past
            now = Time.current.in_time_zone
            @query["date_from"] = (@query["date_from"] || now.ago(1.month)).to_date
            @query["date_to"] = (@query["date_to"] || now).to_date
            days_between_dates = (@query["date_to"] - @query["date_from"]).to_i + 1

            filter_query = filter_query.where(["checks.created_at >= ?", @query["date_from"].beginning_of_day])
                                   .where(["checks.created_at <= ?", @query["date_to"].end_of_day])

            # Parse special check types values
            query_check_types = @query["check_types"]

            case @query["check_types"]
              when "missed", "attendance"
                query_check_types = ["checkin", "delayed"]
            end

            # Check type conditions
            filter_query = filter_query.where(["checks.context IN (?)", Check.values_for(*query_check_types)])

            if @query['check_types'] == 'missed' # Tricky stuff
              comparison = false

              case @query["with"]
                when "gt_0"
                  comparison = '<=' # <= "1 missed day or more"
                when "gt_1"
                  comparison = '<' # "More than 1 missed day"
                when "none"
                  comparison = '>' # "Checked all days"
              end

              if comparison
                # We use days_between_dates-1 as pivot to compare
                @users = filter_query.having(["count(checks.id) #{comparison} ?", days_between_dates - 1])
              end

            else # Other than missed

              case @query["with"]
                when "gt_0"
                  @users = filter_query

                when "gt_1"
                  @users = filter_query.having("count(checks.id) > 1")

                when "none"
                  @users = User.where.not(id: filter_query)
              end
            end
          else # missing params to apply filters; reset
            @check_types_notice = "Check types not selected" if @query["with"].present?
            @comparison_criteria_notice = "Comparison critera not selected" if @query["check_types"].present?

            @query = {} unless @check_types_notice || @comparison_criteria_notice
          end
        end
      end
    end

    @filter_with_options = [
      ["–",""],
      ["At least one","gt_0"],
      ["More than one","gt_1"],
      ["None", "none"],
    ]
    @filter_check_types_options = [
      ["–",""],
      ["Check-in (on time)", "checkin"],
      ["Delayed arrival","delayed"],
      ["Check-out (on time)", "checkout"],
      ["Early departure", "early"],
      ["Attendance", "attendance"],
      ["Missed day", "missed"],
    ]
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
