class SessionsController < ApplicationController
  # セキュリティ上の理由から永続的ではなく一時的な情報にしたい。のでモデルを作らない。
  # なので session = Session.newみたいにはできない。

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password])
      # signupした時、有効化を求められ,root_urlに飛ばされるが、DBにはすでに登録されているのでログインはできてしまう。
      # (activation: false)だとsignupはできないが、ログインはできてしまう。ので以下のように(activation: true)でないと、ログインできないようにする。
      if user.activated?
        log_in(user)
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else
        message  = "Account not activated."
        message += "Check your email"
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # flashの後にrender(requestをもう一度送っている訳ではなく、再描画しているだけ)なのでflash.now
      flash[:danger] = "INVALID EMAIL/PASSWORD COMBINATION"
      render 'new'
    end
  end

  def destroy
    #二つのタブを使い両方ともloginして片方をlogoutする。そしてもう片方のタブをlogoutしようとするとエラーとなる。原因は最初のlogout時に@current_user = nilとなっており、次のlogout時にuser.forgetができない。
    #なので以下のように if logged_in?とすればcurrent_userがnilでなければlogoutメソッドを実行する。　
    log_out if logged_in?
    redirect_to root_url
  end

end
