module Api
  module V1
    class ChecklistTemplatesController < Api::ApiController
      def index
        data = ChecklistTemplate.all.map{|t| t.to_template }
        render p = {json: data, meta: {}, meta_key: :meta, root: :models}
      end
    end
  end
end