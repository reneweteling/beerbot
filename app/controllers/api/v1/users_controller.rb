module Api
  module V1
    class UsersController < ResourcesController
      def stats
        render json: Stats::user
      end
    end
  end
end