ActiveAdmin.register Transaction do

  index do
    selectable_column
    id_column
    column :user
    column :money
    column :amount
    column :paid
    actions
  end

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
