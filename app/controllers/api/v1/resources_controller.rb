module Api
  module V1
    class ResourcesController < Api::ApiController
      before_action :set_class
      before_action :set_collection
      before_action :set_model, only: [:show, :update, :destroy]

      def index
        data = @collection.paginate(page: 1, per_page: 1000)
        meta = {
          page: data.current_page.to_i,
          pages: data.total_pages.to_i,
          per_page: data.per_page
        }.merge extra_meta
        p = {json: data, meta: meta, meta_key: :meta, root: :models}.merge(render_params)
        render p
      end

      def show
        p = {json: @model}.merge(render_params)
        render p
      end

      def create
        @model = @class.create(model_params)

        if @model.save
          p = {json: @model, status: :created, root: false}.merge(render_params)
        else
          p = {json: @model.errors, status: :unprocessable_entity}.merge(render_params)
        end

        render p
      end

      def update
        if @model.update(model_params)
          p = {json: @model, root: false}.merge(render_params)
        else
          p = {json: @model.errors, status: :unprocessable_entity}.merge(render_params)
        end

        render p
      end

      def destroy
        @model.destroy
        head :no_content
      end

      private

      def render_params
        {}
      end
      
      def extra_meta
        {}
      end

      def set_class
        @class = self.class.name.sub('Api::V1::', '').sub('Controller', '').singularize.constantize        
      end

      def set_collection
        @collection = @class.accessible_by(current_ability).order(id: :desc)
      end

      def set_model
        @model = @collection.find(params[:id])
      end

      def default_model_params
        {}
      end

      def model_params
        params.permit(@class.column_names).merge!(default_model_params)
      end
      
    end
  end
end