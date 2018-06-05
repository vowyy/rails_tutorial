class UserMailer < ApplicationMailer
  # app/mailer/user_mailer.rb
  # rails g mailer UserMailer account_activation password_reset

  #以下アクションではなくメソッド。なので引数を渡せる。
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  def password_reset(user)
    @user = user

    mail to: user.email, subject: "Password Reset"
  end
end
