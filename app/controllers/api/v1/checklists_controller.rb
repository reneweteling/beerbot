module Api
  module V1
    class ChecklistsController < ResourcesController

      def model_params
        mp = super

        p = params.map{|key, value| 
          if m = key.match(/^question\[(\d+)\]\[selected\]/) 
            answer = params["question[#{m[1]}][#{value}][answer]"]
            res = {
              # question_id: m[1].to_i,
              checklist_question_option_id: value,
              answer: answer
            }
          end
        }.compact

        mp[:checklist_answers] = p.map{|att| 
          if @model
            # todo, add answer id if we have a model
          end
          ChecklistAnswer.new(att) 
        }

        mp
      end 
      
    end
  end
end