module Api
  module V1
    class ResourcesController < Api::ApiController
      before_action :set_class
      before_action :set_collection
      before_action :set_model, only: [:show, :update, :destroy]

      def index
        render json: @collection
      end

      def show
        render json: @model
      end

      def create
        @model = @class.create(model_params)

        if @model.save
          p = {json: @model, status: :created, root: false}
        else
          p = {json: @model.errors, status: :unprocessable_entity}
        end

        render p
      end

      # def update
      #   if @model.update(model_params)
      #     p = {json: @model, root: false}
      #   else
      #     p = {json: @model.errors, status: :unprocessable_entity}
      #   end

      #   render p
      # end

      # def destroy
      #   @model.destroy
      #   head :no_content
      # end

      private
      def set_class
        @class = self.class.name.sub('Api::V1::', '').sub('Controller', '').singularize.constantize        
      end

      def set_collection
        @collection = @class.order(id: :desc)
      end

      def set_model
        @model = @collection.find(params[:id])
      end

      def model_params
        params.permit(@class.column_names)
      end
      
    end
  end
end