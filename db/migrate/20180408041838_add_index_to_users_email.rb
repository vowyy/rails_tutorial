class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :email, unique: true
    # rails側にはuser.rbにてuniqueness{case_sensitive: true}とあるが
    # データベース側にuniqueを保証してもらう。
  end
end
