class CreateMicroposts < ActiveRecord::Migration[5.1]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, foreign_key: true
      # user_id:referencesの省略形
      # microopst.rbにてbelong_to :userを書かなくても自動で書いてくれる。
      t.timestamps
    end
    add_index :microposts, [:user_id, :created_at]
      #以前の一意性のためではなくて、今回は高速化のためのindexをかける。
      #DBに問い合わせするたびにいつ投稿したかを見るのでcreated_atをインデックスかける。(複合キーインデックス。)
  end
end
