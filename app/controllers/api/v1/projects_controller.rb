module Api
  module V1
    class ProjectsController < ResourcesController
      def set_collection
        super
        @collection = @collection.active
      end
    end
  end
end