ActiveAdmin.register Beer do

  index do
    selectable_column
    id_column
    column :amount
    column :user, sortable: :user_id do |col|
      col.user.to_s
    end
    column :date, sortable: :created_at  do |col|
      col.created_at.to_date
    end
    column :created_at
    actions
  end

  csv do
    column :amount
    column :user do |row| 
      row.user.to_s 
    end
    column :date, sortable: :created_at  do |col|
      col.created_at.to_date
    end
    column :created_at
  end

  controller do
    def scoped_collection
      super.includes :user
    end
  end

end
