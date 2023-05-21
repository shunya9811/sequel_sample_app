class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  # GET /users
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  # GET /users/:id
  def show
    @user = User.find(params[:id])
    # => app/views/users/show.html.erb
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated?
  end

  # GET /users/new
  def new
    @user = User.new
    # => app/views/users/new.html.erb
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  # GET /users/:id/edit	
  def edit
  end

  # PATCH /users/:id
  def update
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  # DELETE 	/users/:id
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  private
    # Strong Parameters
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # beforeフィルタ

    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url, status: :see_other
      end
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end
