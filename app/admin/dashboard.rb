ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span "Beers consumed: #{Beer.consumed.count} bought: #{Beer.bought.count}"
        h2 "There should be #{Beer.bought.count - Beer.consumed.count} in stock"
      end
    end

  end
end