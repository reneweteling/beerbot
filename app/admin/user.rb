ActiveAdmin.register User do

  form do |f|
    f.inputs "Admin Details" do
      f.input :first_name
      f.input :last_name
      f.input :slack_username
      f.input :role
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
  
  controller do
    def update
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super
    end

    def destroy
      # Before destroy, Checking associated
      user = User.find(params[:id])
      if user.destroy
        super
      else
        redirect_to admin_user_path(user), :alert => "#{user.errors.messages[:base].last}"
      end
    end
  end

end
