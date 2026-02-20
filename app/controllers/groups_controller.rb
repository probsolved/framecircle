class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :show, :edit, :update, :destroy, :manage ]

  # =========================================================
  # INDEX — list groups + unread badge per group
  # =========================================================
  def index
    @memberships = current_user
      .group_memberships
      .includes(:group)

    group_ids = @memberships.map(&:group_id)

    @unread_counts = Notification.unread
      .where(
        recipient_id: current_user.id,
        group_id: group_ids
      )
      .group(:group_id)
      .count
  end

  # =========================================================
  # SHOW — group overview + unread badge per week
  # (DO NOT mark anything as read here)
  # =========================================================
  def show
    @weeks = @group.weeks.order(starts_on: :desc)

    week_ids = @weeks.map(&:id)

    @unread_by_week = Notification.unread
      .where(
        recipient_id: current_user.id,
        group_id: @group.id,
        week_id: week_ids
      )
      .group(:week_id)
      .count
  end

  # =========================================================
  # CRUD
  # =========================================================
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.owner = current_user

    if @group.save
      GroupMembership.find_or_create_by!(group: @group, user: current_user) do |m|
        m.role   = :admin  if m.respond_to?(:role)
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
    unless current_user.admin? || current_user.id == @group.owner_id
      return redirect_to group_path(@group), alert: "Not authorized."
    end

    @group.destroy!
    redirect_to groups_path, notice: "Group deleted."
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to group_path(@group), alert: e.message
  end

  # =========================================================
  # MANAGEMENT / DISCOVERY
  # =========================================================
  def manage
    @memberships = GroupMembership
      .includes(:user)
      .where(group: @group)
      .order(:created_at)
  end

  def discover
    @groups = Group.where(public: true).order(created_at: :desc)
  end

  # =========================================================
  # PRIVATE
  # =========================================================
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
