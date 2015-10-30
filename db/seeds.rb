if Rails.env.development?

  rene = User.create!(first_name: 'René', email: 'rene@weteling.com', password: 'password', password_confirmation: 'password')
  User.create!(first_name: 'Emile', email: 'emile@me.com', password: 'password', password_confirmation: 'password')
  User.create!(first_name: 'Thijs', email: 'thijs@me.com', password: 'password', password_confirmation: 'password')
  User.create!(first_name: 'Bas', email: 'bas@me.com', password: 'password', password_confirmation: 'password')
  User.create!(first_name: 'Ray', email: 'ray@me.com', password: 'password', password_confirmation: 'password')
  User.create!(first_name: 'Arjan', email: 'arjan@me.com', password: 'password', password_confirmation: 'password')
  User.create!(first_name: 'Erick', email: 'erick@me.com', password: 'password', password_confirmation: 'password')
  User.create!(first_name: 'Pim', email: 'pim@me.com', password: 'password', password_confirmation: 'password')
  User.create!(first_name: 'Oscar', email: 'oscar@me.com', password: 'password', password_confirmation: 'password')
  User.create!(first_name: 'Joost', email: 'joost@me.com', password: 'password', password_confirmation: 'password')
  User.create!(first_name: 'Sander', email: 'sander@me.com', password: 'password', password_confirmation: 'password')
  User.create!(first_name: 'Pieter-jan', email: 'pj@me.com', password: 'password', password_confirmation: 'password')

  User.all.each do |u|
    10.times do
      u.beers.create!(amount: rand(-5..6), creator: rene)
    end
  end

else

  pass = SecureRandom.hex(6)
  User.create!(first_name: 'René', last_name: 'Weteling', email: 'rene@weteling.com', password: pass, password_confirmation: pass)
  
end