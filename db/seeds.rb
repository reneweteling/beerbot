rene = User.create!(first_name: 'René', email: 'rene@weteling.com', password: 'password', password_confirmation: 'password')
User.create!(first_name: 'Emile', email: 'emile@me.com')
User.create!(first_name: 'Thijs', email: 'thijs@me.com')
User.create!(first_name: 'Bas', email: 'bas@me.com')
User.create!(first_name: 'Ray', email: 'ray@me.com')
User.create!(first_name: 'Arjan', email: 'arjan@me.com')
User.create!(first_name: 'Erick', email: 'erick@me.com')
User.create!(first_name: 'Pim', email: 'pim@me.com')
User.create!(first_name: 'Oscar', email: 'oscar@me.com')
User.create!(first_name: 'Joost', email: 'joost@me.com')
User.create!(first_name: 'Sander', email: 'sander@me.com')
User.create!(first_name: 'Pieter-jan', email: 'pj@me.com')

User.all.each do |u|
  10.times do
    u.beers.create!(amount: rand(-5..6), creator: rene)
  end
end