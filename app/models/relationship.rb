class Relationship < ApplicationRecord
  # belongs_to :user => "{table}_id"を探し始めるのでダメ。

  # follower_id, followed_idがテーブルにある。
  # followerクラス,followedクラスはないのでUserクラスを見に行ってください。
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # Relationship.first.follower => @user が手に入る。
end
