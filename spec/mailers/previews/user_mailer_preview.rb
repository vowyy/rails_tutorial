class UserMailerPreview < ActionMailer::Preview
  #実際にforget_passwordをしてメールを送らせなくてもここの記述をして以下にあるurlにアクセスすれはメールの文面などを確認できるY。
  # Preview this email at http://0.0.0.0:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first
    user.activation_token = User.new_token
    UserMailer.account_activation(user)
    # user_mailer.rbにあるaccount_activation(user)にとばす。
    # 最後の行でMailオブジェクトが返ってきて、それを上のurlでpreviewできる。
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    user.reset_token = User.new_token
    UserMailer.password_reset(user)
  end

end
