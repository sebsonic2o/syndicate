# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# User.create(
#   username: "Rob",
#   image_url: "https://secure.gravatar.com/avatar/18bb2e449dc97f0fe668484d81019402.png?r=PG&d=mm&s=150"
# )
# User.create(
#   username: "Sebastien",
#   image_url: "https://secure.gravatar.com/avatar/3220ca30faecef1688c8e23801aab58e.png?r=PG&d=mm&s=150"
# )
# User.create(
#   username: "Tania",
#   image_url: "https://secure.gravatar.com/avatar/4a534bf489347b3327c0f8a5492070c0.png?r=PG&d=mm&s=150"
# )
# User.create(
#   username: "Jonathan",
#   image_url: "https://secure.gravatar.com/avatar/53b0c49cbb13f2837215b6b0ab6ee45d.png?r=PG&d=mm&s=150"
# )


# 30.times do
#   User.create(
#     username: Faker::Internet.email,
#     first_name: Faker::Name.first_name,
#     last_name: Faker::Name.last_name,
#     image_url: Faker::Avatar.image.gsub(/http/, "https")
#   )
# end

#custom seeds
issue1 = Issue.create(
  title: "Should fog be banned from San Francisco?",
  description: "Fog can contain lots of pollution that ails the air around our beautiful San Francsico, and also cause problems with visibility - both in covering up our beautiful landmarks, and causing problems for our motorists.  Also, it's wet.",
  image_url: "golden.jpg",
  # start_date: Faker::Time.between(2.days.ago, Time.now, :all),
  # finish_date: Faker::Time.forward(23, :all),
  start_date: DateTime.now,
  finish_date: "2015-06-24 16:31:00 -0700",
  creator_id: 1,
  group_id: 1
)
# issue1.voters = User.all

issue2 = Issue.create(
  title: "Should we paint the skies?",
  description: "Auroras are natural light displays in the sky.  We can allow more people to see them by painting the skies in multiple locations around the United States.  And, they're really cool.",
  image_url: "aurora.jpg",
  start_date: Faker::Time.between(2.days.ago, Time.now, :all),
  finish_date: Faker::Time.forward(4, :all),
  creator_id: 1,
  group_id: 1
)
# issue2.voters = User.all

issue3 = Issue.create(
  title: "Should Sherif Abushadi be the next President of the United States?",
  description: "A man who has truly embranced his internal ball of intense, white hot confusion.  Writes the most brilliant web apps and destroys them before anyone else can see, FOR FUN.  Never afraid to announce the bullshit he sees.  He doesn't know what the hell he's doing, and neither does anyone else.",
  image_url: "sherif.jpg",
  start_date: Faker::Time.between(2.days.ago, Time.now, :all),
  finish_date: "2015-06-26 11:30:00 -0700",
  creator_id: 1,
  group_id: 1
)
# issue3.voters = User.all

issue4 = Issue.create(
  title: "Should dogs replace cats?",
  description: "In general, dogs are more friendly than cats are.  Their loyalty and happiness to see their human is peerless.  In a way, dogs are the ultimate companion.  I would like to vote that all dogs should replace cats.  Does everyone else agree?  VOTE NOW!",
  image_url: "dog.jpg",
  start_date: Faker::Time.between(2.days.ago, Time.now, :all),
  finish_date: Faker::Time.forward(4, :all),
  creator_id: 1,
  group_id: 1
)
# issue4.voters = User.all

issue5 = Issue.create(
  title: "Should we melt this mountain to solve California's water crisis?",
  description: "Let's be real, lake tahoe's snow conditions have really sucked in the last 10 years anyway.  No one would really miss this one mountain if we, like, blew it up a little and melted the snow to help with California water situation.",
  image_url: "mountain.jpg",
  start_date: Faker::Time.between(2.days.ago, Time.now, :all),
  finish_date: Faker::Time.forward(4, :all),
  creator_id: 1,
  group_id: 1
)
# issue5.voters = User.all

issue6 = Issue.create(
  title: "Should the Leaning Tower of Pisa be corrected?",
  description: "This tower is a danger to the city of Pisa.  Its weight is an estimated 14,500 metric tons - imagine if it were to topple over in an earthquake or under terrorist attack.  The tower should clearly be uprighted as a service to the people of Pisa and their fears assuaged.",
  image_url: "pisa.jpg",
  start_date: Faker::Time.between(2.days.ago, Time.now, :all),
  finish_date: Faker::Time.forward(4, :all),
  creator_id: 1,
  group_id: 1
)
# issue6.voters = User.all

# 47.times do
#   issue = Issue.create(
#       title: Faker::Lorem.sentence,
#       description: Faker::Lorem.paragraph(3),
#       image_url: Faker::Avatar.image.gsub(/http/, "https"),
#       start_date: Faker::Time.between(2.days.ago, Time.now, :all),
#       finish_date: Faker::Time.forward(23, :all),
#       creator_id: 1,
#       group_id: 1
#   )

#   issue.voters = User.all
# end


