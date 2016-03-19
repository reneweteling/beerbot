module Api
  module V1
    class HoursController < ResourcesController
      def set_collection
        super
        @collection = @collection.where("hours.start_at > ?" , Time.zone.now - 7.days)
        @collection = @collection.where(project_id: params[:project_id]) if params[:project_id]
      end

      def model_params
        p = super
        p['signature_data'] = params['signature_data'] if params['signature_data'].kind_of? String
        p
      end
      
    end
  end
end