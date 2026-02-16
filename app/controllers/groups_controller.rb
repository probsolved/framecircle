class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :show, :edit, :update, :destroy ]

  def index
    @groups = Group
      .left_joins(:group_memberships)
      .where("groups.owner_id = :uid OR group_memberships.user_id = :uid", uid: current_user.id)
      .distinct
      .order(created_at: :desc)
  end

  def show
    @weeks = @group.weeks.order(starts_on: :desc)
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.owner = current_user

    if @group.save
      # Ensure creator is also a member/admin
      GroupMembership.find_or_create_by!(group: @group, user: current_user) do |m|
        m.role = :admin if m.respond_to?(:role)
        m.status = :active if m.respond_to?(:status)
      end

      redirect_to group_path(@group), notice: "Group created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    require_owner_or_admin!
  end

  def update
    require_owner_or_admin!

    if @group.update(group_params)
      redirect_to group_manage_path(@group), notice: "Group updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: "Group deleted."
  end

  def manage
  @group = Group.find_by!(slug: params[:slug])

  @memberships = GroupMembership
    .includes(:user)
    .where(group: @group)
    .order(:created_at)
  end

  def discover
  @groups = Group.where(public: true).order(created_at: :desc)
  end

  private



  def set_group
    @group = Group.find_by!(slug: params[:slug])
  end

  def group_params
  params.require(:group).permit(:name, :public)
  end

  def require_owner_or_admin!
    return if @group.owner_id == current_user.id

    m = GroupMembership.find_by(group: @group, user: current_user)
    ok = m&.role.to_s == "admin" && m&.status.to_s == "active"
    redirect_to group_path(@group), alert: "Not allowed." unless ok
  end
end
