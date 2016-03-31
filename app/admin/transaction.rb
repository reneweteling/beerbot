ActiveAdmin.register Transaction do

  form do |f|
    f.inputs do
      f.input :user
      f.input :money
      f.input :amount
      f.input :paid
    end
    f.actions
  end
  
end
