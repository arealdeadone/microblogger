class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,:following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user, only: :destroy
  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    @users = User.new
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def create
    @users = User.new(user_params)
    @users.update_attributes(activated: true, activated_at: Time.zone.now)
    if @users.save
      # @users.send_activation_email
      default_follow = User.find(1)
      default_follow.follow(@users)
      @users.follow(default_follow)
      flash[:success] = "You can now login."
      redirect_to login_path
    else
      render 'new'
    end

  end

  def edit
    @users = User.find(params[:id])
  end

  def update
    @users = User.find(params[:id])
    if @users.update_attributes(user_params_update)
      flash[:success] = "Profile updated"
      redirect_to @users
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def user_params_update
      params.require(:user).permit(:name, :password, :password_confirmation)
    end

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please Log In"
        redirect_to login_url
      end
    end

    def correct_user
      @users = User.find(params[:id])
      redirect_to(root_url) unless current_user? @users
    end

    def admin_user
      redirect_to root_url unless current_user.admin?
    end
end
