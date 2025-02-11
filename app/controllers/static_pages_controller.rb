class StaticPagesController < ApplicationController
    # layout -> { params[:inventory_id].present? ? 'application' : 'base' }
    allow_unauthenticated_access only: [:home, :help, :about]
    before_action :resume_session, only: [:home, :help, :about]

    def home
    end

    def help
    end

    def about
    end
end
