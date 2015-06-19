# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
30.times do
  User.create(username: Faker::Name.first_name)
end

50.times do
  issue = Issue.create(
      title: Faker::Lorem.sentence,
      description: Faker::Lorem.paragraph(3),
      image_url: "/images/sherif.jpg",
      start_date: Faker::Time.between(2.days.ago, Time.now, :all),
      finish_date: Faker::Time.forward(23, :all),
      creator_id: 1,
      group_id: 1
  )

  issue.voters = User.all
end

30.times do
  User.create(
    username: Faker::Name.first_name
  )
end
