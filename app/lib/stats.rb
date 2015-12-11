class Stats
  def self.user

    beer_by_date = Beer.bought.group("DATE(created_at), user_id")
      .where("created_at > ?", 30.days.ago)
      .select("DATE(created_at) as date", :user_id, "SUM(amount) as amount")
      .order("DATE(created_at) asc")

    dates = {}
    beer_by_date.each do |b|
      if dates[b.date].present?
        dates[b.date].push(b) 
      else
        dates[b.date] = [b]
      end
    end

    users = User.order(:first_name).where('beer_consumed > ?', 0)
    data = [ ['Datum'] + users.collect{|u| u.first_name } ]
    dates.each do |date, beer|
      row = [ date.strftime("%Y-%m-%d") ]
      beer_users = beer.collect{|b| b.user_id }
      users.each do |user|
        index = beer_users.index user.id
        unless index.nil?
          row << beer[index].amount
          next
        end
        row << 0
      end
      data << row
    end

    data

  end
end