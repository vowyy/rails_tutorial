#データベースに保存する時rails consoleでできることをスクリプトとして実行できる。
# rails db:migrate:reset(データベースの中身消す。) →　rails db:seed
User.create!(name:  "Example User", email: "example@railstutorial.org", password: "foobar", password_confirmation: "foobar", admin: true, activated: true, activated_at: Time.zone.now)
#後ほどadminを追加する時のために一人だけ普通に作る。
#create!の理由はseed.rbはmigrationファイルと違って冪等性ではないのでseed.rbを二回実行してもここにある100人分のレコードを全員分の作成を試みて、毎回失敗してしまう。
#ので最初の一人目であるExample Userが作られた時点でemailが被ってしまってvalidationが失敗した時点で処理を止める。(１００人ならまだいいが10000人いた場合はどうせ失敗するなら1人目で終えたい。)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org" #必ずemailがuniqueになるようにする。
  password = "password"
  User.create!(name:  name, email: email, password: password, password_confirmation: password, activated: true, activated_at: Time.zone.now)
end


users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
end

#リレーションシップ
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
