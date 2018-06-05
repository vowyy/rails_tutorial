class Micropost < ApplicationRecord
  belongs_to :user
  #user:referencesで自動的に追加された。

  #pictureカラムを作り以下のメソッドを追加。(carrierwaveの作法なのでrailsとはあまり関係ない。documentを読むしかない。)
  mount_uploader :picture, PictureUploader

  validates :user_id, presence: true
  validates :content, presence: true,
                        length: { maximum: 140 }
  validate :picture_size
  #独自のバリデーション。その場合はvalidate。
  # gem 'minimagic' 画像のサイズ加工。

  default_scope -> { order(created_at: :desc) }
  # Micropostの表示順序を降順(最新順)にする。
  # Micoropost.firstで最新の投稿が手に入る。
  # プロックにしたのはその時の降順が欲しいから。(遅延評価)その時必要になったら欲しいから。

  # ->{○○○}　はRubyのProcオブジェクト
  # 例) p = -> { print 'foo'}; p.call => 'foo'
  # ブロックはコードの塊でそれをeachやmapなどのメソッドに渡していたが、そのコードの塊を一旦変数に入れ、実行したくなった時にcallで実行。

  private

  def picture_size
    if picture.size > 1.megabytes
      erros.add(:picture, "shold be less than 1Mb")
    end
  end
end
