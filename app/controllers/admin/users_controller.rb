class Admin::UsersController < Admin::BaseController
  def index
    q = params[:q].to_s.strip
    @users =
      if q.present?
        User.where("email ILIKE ? OR display_name ILIKE ?", "%#{q}%", "%#{q}%")
      else
        User.all
      end.order(created_at: :desc).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  user = User.find(params[:id])

  return redirect_to admin_users_path, alert: "You can’t delete your own account." if user == current_user

  ActiveRecord::Base.transaction do
    # Transfer any groups they own to the admin performing the deletion
    Group.where(owner_id: user.id).update_all(owner_id: current_user.id)

    # Everything else cascades automatically now
    user.destroy!
  end

  redirect_to admin_users_path, notice: "User deleted. Any groups they owned were transferred to you."
  rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::InvalidForeignKey => e
  redirect_to admin_users_path, alert: e.message
  end

  def promote_to_admin
    user = User.find(params[:id])
    user.update!(admin: true)
    redirect_back fallback_location: admin_user_path(user), notice: "Promoted to site admin."
  end

  def demote_from_admin
    user = User.find(params[:id])
    user.update!(admin: false)
    redirect_back fallback_location: admin_user_path(user), notice: "Removed site admin."
  end

  private

  def user_params
    params.require(:user).permit(:display_name, :location, :frames_username, :admin)
  end
end
