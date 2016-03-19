module Api
  module V1
    class ProjectDiariesController < ResourcesController

      def update
        if params[:uploads]
          params[:uploads].each do |data|
            @model.diary_uploads.create data: data
          end
        end
        super
      end


      def default_model_params
        { user_id: current_user.id }
      end

      def set_collection
        super
        @collection = @collection.where(project_id: params[:project_id]) if params[:project_id]
        @collection = @collection.includes(:diary_uploads)
      end

    end
  end
end