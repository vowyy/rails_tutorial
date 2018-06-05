class AccountActivationsController < ApplicationController

  #signupの時に自動で作られた (activation: false) をtrueにしたいのでnewではなくedit

  #ユーザーが送られてきたメールにあるリンクを踏むと問答無用でGETリクエストが飛ぶ。なので、
  #いつもはcreateアクション(POST)やupdateアクション(PATCH)でやっているような処理をここで書く。(createやupdateに飛ばすことはできない。)
  def edit
     @user = User.find_by(email: params[:email])

     if @user && !@user.activated && @user.authenticated?(:activation, params[:id])
       #ユーザーはDBにあるか？ && このユーザーは(activated: false)だよね？ && リンクに組み込まれていたactivation_tokenとDBに保存してあるactivation_digestは一致する？
       @user.activate
       # @user.update_attribute(:activated, true)
       # @user.update_attribute(:activated_at, Time.zone.now)

      log_in @user
      flash[:success] = "Account activated"
      redirect_to @user
     else
       flash[:danger] = "Invalid activation link"
       redirect_to root_url
     end
  end
end
