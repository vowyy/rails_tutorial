class RelationshipsController < ApplicationController
  before_action :logged_in_user

  # def new
  #   @relationship = current_user.active_relationships.build
  # end
  # form_for(current_user.active_relationships.build) do |f| で定義してあるのでいらない。

  def create
     # POST /relationships
     # hiddenで渡されたfollowed_idを使ってなんとか自分がフォローするuserを取ってくる。
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    #データベースへの処理はrespond_to内で行なったも良い。
    respond_to do |format|
      format.html { redirect_to @user }# 基本的な流れ。
      format.js                        # javascript(xhr)からリクエストが来たら
      #引数に何もないのでデフォルト値(create.js.erb)が動く
    end
  end

  def destroy
    # DELETE /relationships/:id
    # :idには(current_user.active_relationships.find_by(followed_id: @user.id))が入っている。これは下で使う。
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
      #引数に何もないのでデフォルト値(destroy.js.erb)が動く
    end
  end

end
