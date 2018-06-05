# ここにあるファクトリーはRSpecによって自動的に読み込まれる。
# BCryptアルゴリズムによるセキュアパスワードのハッシュ生成そのものが仕様上遅いのが原因で実行すると遅い。
#ので、test.rbにてbcryptのコスト関数を下げることでテストの速度を向上させるためのコードを追加。
FactoryGirl.define do
  # シンボル:userがfactoryコマンドに渡されると、Factory Girlはそれに続く定義がUserモデルオブジェクトを対象としていることを認識する。
  # factory :user do
  #   name     "Michael Hartl"
  #   email    "michael@example.com"
  #   password "foobar"
  #   password_confirmation "foobar"
  # end

  #ページネーション用
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
    #FactoryGirl.create(:admin)を使用してテスト内に管理ユーザーを作成することができるようになる
  end
　#sequenceメソッドの引数には、使用したい属性に対応するシンボル (:name など) を使用し、nという変数を持つブロックを1つ置く。

  # before(:all) { 30.times { FactoryGirl.create(:user) } }
  # after(:all)  { User.delete_all }
  # こんな感じにすれはok

  factory :micropost do
    content "Lorem ipsum"
    user #このかきかたでok
  end
  # FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)みたいにかける。
end
