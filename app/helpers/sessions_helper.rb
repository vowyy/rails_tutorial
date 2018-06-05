module SessionsHelper #メソッドのパッケージ

  #渡されたユーザーでログインする。
  def log_in(user)
   session[:user_id] = user.id
  end

  # def current_user
  #   @current_user ||= User.find_by(id: session[:user_id])
  #   # @current_user = @current_user || User.find_by(id: session[:user_id])
  #   # 一つのページでcurrent_userを二回使う場合はこの書き方は良い。 => メモ化
  # end

  def current_user?(user)
    user == current_user
  end

  def current_user

    #１、ログイン済みのユーザーの場合。(すでにlog_inメソッドが実行されており、sessionにuser_idがある場合。)
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    #２、ログイン済みのユーザーではないが(ログアウトをしてsession[:user_id].deleteをした。)過去ログイン時にremember_meボタンにチェックを入れ、cookie情報がある場合。
    elsif (user_id = cookies.signed[:user_id]) #2回目のsignedで復号化できる。
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
    #３、初めてのログイン、または過去にログインしたことがあるがremember_meボタンにチェックを入れなかったためcookie情報がないのでもう一度ログインを促す。
  end


  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    #cookie系のデータを全て削除。
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
    # 毎回上の二行を描いても良いがせっかくなのでメソッド化する。
  end

  def remember(user)
    user.remember #token作成とそれのdigestを作成、データベースに保存する処理をuser.rbにて。
    cookies.permanent.signed[:user_id] = user.id
    #cookies.signed[:user_id])で復号化.(2回目のsignedで復号化できる。)

    cookies.permanent[:remember_token] = user.remember_token
    #いつexpireするかの値を必ず設定しなければいけない。permanentは20年間。
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location
    #forwarding_urlに代入されうる値。         #redirect_toはGETリクエストを送るので、
     # (edit_path)   GET   /users/1/edit => GET /users/1/edi => userのeditページへ
     # (update_path) PATCH /users/1      => GET /users/1     => userのshowページへ

    session[:forwarding_url] = request.original_url if request.get?
    # request.get?にしないとredirect_toは結局getを送るから意味がない。
    # request →　getとかpatchとかpostとか
    # original_url → /users/1/edit

  end

end
