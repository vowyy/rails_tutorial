class PasswordResetsController < ApplicationController
before_action :get_user, only: [:edit, :update]
before_action :right_user, only: [:edit, :update]
before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)

    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password"
      redirect_to root_url
    else
      flash.now[:danger] = "Email not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      # 新しいパスワードが空文字列になっていないか (ユーザー情報の編集ではパスワードが空でも(allow_nil: true)でOKだった
     @user.errors.add(:password, :blank) #自分でバリデーションをかける
     render 'edit'
   elsif @user.update_attributes(user_params) #formのpasswordが空ではなかったら、そのパスワードを更新するに値するかどうかのvalidationをかける
      # 新しいパスワードが正しければ、更新する
     log_in @user
     flash[:success] = "Password has been reset."
     redirect_to @user
    else
     # 無効なパスワードであれば失敗させる (失敗した理由もshard/error_messagesで表示する)
     render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def right_user
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "password reset has expired"
      redirect_to new_password_reset_url
    end
  end
end
