class User < ApplicationRecord
  #ApplicatinRecordがあることによりそれが使えるメソッド（データベースとの通訳）をUserモデルが使える。
  #モデルは失敗すると地名的なので慎重に。

  attr_accessor :remember_token, :activation_token, :reset_token
  #メソッドとして一時的に保存してアクセスする場所は作るが、すぐ消える。
  # def remember_token
  #   @remember_token
  # end
  #
  # def remember_token=(str)
  #   @rmember_token = str
  # end

   #下で大文字小文字区別しないようにしているが、一応コールバックで全てのemailを小文字にしてデーターベースに保存。
  before_save :downcase_email #before_saveはcreateとupdate時に実行される
  before_create :create_activation_digest#before_createはcreate時のみ実行される


  has_many :microposts, dependent: :destroy
#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
  has_many :active_relationships,                   # ActiveRelatinshipsクラスを見に行ってしまうので,
                        class_name: "Relationship", # Relationshipクラスを見に行ってください。
                       foreign_key: "follower_id",  # 上のクラスのなかでuser_idを見に行かないで自分のidとfollower_idを紐ずけて。(外部キー)
                         dependent: :destroy
  # やりたい事は -> user.active_relationships    => relationshipテーブルでfollower_idがuserのidのレコードを全て取ってくる。

  has_many :following, through: :active_relationships, source: :followed
  # やりたい事は -> user.following        => 自分がフォローしているuserの集合を取る
  # user.active_relations.followed == user.following

  # user = User.first
  # user.active_relationships.create(followed_id: 2) => <Relationship id: 3, follower_id: 1, followed_id: 2,,,,>
  # Relationship.first.follower                      => usersテーブルのidが１のユーザーが返される。
  # Relationship.first.followed                      => usersテーブルのidが２のユーザーが返される。

 has_many :passive_relationships,
                        class_name: "Relationship",
                       foreign_key: "followed_id",
                         dependent: :destroy

 has_many :followers, through: :passive_relationships, source: :follower

#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
  #よくあるバリデーションはオプションがもともと存在する。ただ、ないものに関しては自分で作れる。
  validates :name,  presence: true, #空白文字列の連結などは弾かれる。
                      length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                      length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                  uniqueness: { case_sensitive: false } #大文字小文字を区別しない。

  has_secure_password #デフォルトで空かどうかを調べてくれるので "password_can't be blank"が二つでる。ただ、空白文字列は弾かない。(文字としてみなす。)
  # passwordとpassword_confirmationを使えるようになるが実体を持たない。一時的にメモリ上に置き、データベースには保存されない
  # user.password = "tomohiro17"みたいにはできるが、それはハッシュ化されてpassword_digestに登録される。
  # user.authenticate "tomohiro17"みたいに使える。オブジェクトかfalseが返る。
  # (準備)
  # 1 password_digestカラムを追加
  # 2 gem 'bcrypt'を追加
  # 3 has_secure_passwordをuser.rbに追加
  validates :password, presence: true,
                         length: { minimum: 6 },
                      allow_nil: true #editページなどでpasswordを入力しなかったら既存のものを引き継ぐ。newページだとそもそもデータベースにpasswordがないのでpresence: trueでエラー。

  #ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    #production環境、test環境でpasswordをダイジェスト時に,どれだけ複雑にするか。
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  #ランダムなトークン(文字列)を返す。tutorialではremember_meのためにブラウザに置く値(remember_token)を作成時に使う。
  #BCriptと違い復号化できる。
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    # データベースサイドの処理をするrememberメソッド
    #一時的だがremember_tokenに保存
    self.remember_token = User.new_token
    self.update_attribute(:remember_diget, User.digest(remember_token))
    #update_attributeでバリデーションをかけずに保存する。人間ではなくコンピューターが保存するだけなのでバリデーションをかけない。
  end

  # has_secure_passwordのauthenticateはpasswordとそのdigestを付き合わせるものなので、rememberように作る。

  def authenticated?(attribute, token)# def authenticated?(remember_token)決め打ちだった。
    #safariとchromeの二種類のブラウザを立ち上げてsafariをlogoutする。そしてchromeのブラウザを閉じる(sessionを無効にする)。chromeをもう一度立ち上げるとエラー。
    #理由はcurrent_userが取れないということ。chromeにはまだcookie情報はあるが、safariでlogoutしたのでremember_digestがnilになっている。 なのでcurrent_userメソッド内のcookie情報でuserの情報を取ろうとした時に,
    #cookie[:user_id]とcookie[:remember_token]は取れるがそれらを使って探し当てたuserのremember_tokenとremember_digestをここのメソッドで比べるとremember_digestはsafariでlogoutした時にすでnilとなっているので
    #エラーが起こる。なので以下のようにする。
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  # 一人のuserが持つdigest, tokenの種類
  # remember_digest && remember_token
  # activation_digest && activation_token
  # reset_digest && reset_token


  #ユーザーのログイン情報を破棄する。
  def forget
    update_attribute(:remember_digest, nil)
    #必ずauthenticated?が失敗する。
  end

  def activated
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    #reset_sent_atの値が2時間前より早い場合。
    reset_sent_at < 2.hours.ago
  end

  #whereを使って今の所はMicropost全体の中からusr_idカラムが自分のidのものを返す。
  def feed
    # Micropost.where("user_id = ?", self.id)
    # (基本形)
    #  Micropost.where("user_id IN (?) OR user_id = ?",
    #                                    self.following_ids, self.id)
    #
    # (進化形)
    #  Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
    #                                    following_ids: self.following_ids, user_id: self.id)
    # Micoropost.where(....)とself.followingで合計2回DBに問い合わせをしてしまっているので,
    # 以下のようにサブセレクトに置き換える。

    #(最終形) サブセレクト
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)

　　　# where文の中にクエリを入れていく。
    # 1つ目の?に第二引数が、2つ目の?に第三引数が入る。
    # following_idsは配列だが、Railsがうまく文字列にしてくれる。

    # 自分の投稿＋フォローしている人の投稿
    # current_user.microposts + current_user.following.map(&:microposts)
    # 逐次的プログラミングの世界(Railsとか)では複数行のコードで目的を達成すうのでこれでも良い。
    # 宣言的プログラミングの世界(DB)では一つの問い合わせにまとめるのでこれではダメ。。
  end

  #ユーザーをフォローする。
  def follow(other_user)
    self.active_relationships.create(followed_id: other_user.id)
  end


  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end


  #現在のユーザーがフォローしていたらtrueを返す。
  def following?(other_user)
    following.include?(other_user)
  end


  private

  def downcase_email
    self.email = self.email.downcase
  end

  #コントローラー上で全ての行程(StrongParameterやvalidate)も通って,いざ新規ユーザーをDBに登録する直前でこのメソッドを挟むことによりaccivation_digesgtも一緒に保存
  #コントローラーのbefore_actionではない理由は,その時点ではDBに保存しうるユーザーかどうかわからないから。
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
