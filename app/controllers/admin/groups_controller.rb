# app/controllers/admin/groups_controller.rb
module Admin
  class GroupsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    def index
      @groups = Group
        .includes(:owner, :group_memberships)
        .order(created_at: :desc)
    end

    private

    def require_admin!
      # TEMP: allow site owner by email
      # Later we’ll replace this with a real admin role
      allowed_admins = [
        "paul@probsolved.dev" # change to your real email
      ]

      unless allowed_admins.include?(current_user.email)
        redirect_to root_path, alert: "Not authorized"
      end
    end
  end
end
