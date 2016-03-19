module Api
  module V1
    class ExposureHoursController < ResourcesController
      def set_collection
        super
        @collection = @collection.where(project_id: params[:project_id]) if params[:project_id]
        @collection = @collection.where(hour_id: params[:hour_id]) if params[:hour_id]
        @collection = @collection.where(user_id: params[:user_id]) if params[:user_id]
      end

    end
  end
end