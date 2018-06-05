class UsersController < ApplicationController
 before_action :logged_in_user, only: [:edit, :update, :index, :destroy, :following, :followers]
 before_action :right_user,     only: [:edit, :update]
 before_action :admin_user,     only: :destroy
 #誰でも編集,更新できてしまうのでログインしていて且つ自分自身なら可能。
 #シンボルで文字列を渡すとメソッド名だとわかる。Rubyの慣習。
 #全てのアクションにlogged_in_userを指定しまうとclosedなwebサイトになってしまうのでeditとupdateだけに限定。

  def index
    #@users = User.all
    @users = User.paginate(page: params[:page])
    # paramsの中にpage:２みたいなのが入ってくる。1ページ目(http://0.0.0.0:3000/users)2ページ目以降(http://0.0.0.0:3000/users?page=2)
    # デフォルト値は30人ごと。
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new #空のインスタンスを作成。
  end

  def create
    # @user = User.new(name: params[:user][:name], email: params[:user][:email], passoword: ,,,,,,,,)
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email"
      redirect_to root_url
      #メールで認証してからログインするのでここでの処理はacount_activationコントローラーに移す。
      # redirect_to @user
      # log_in @user
      # flash[:success] = "Welcome to the Sample App!"
    else
     render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "完了したよ。"
      redirect_to @user
    else
     render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_path
  end

  def following
   @title = "Following"
   @user  = User.find(params[:id])
   @users = @user.following.paginate(page: params[:page])
   render 'show_follow'
  end

  def followers
   @title = "Followers"
   @user  = User.find(params[:id])
   @users = @user.followers.paginate(page: params[:page])
   render 'show_follow'
  end

  private
  #コントローラーの以外から呼び出せない。user_paramsはセキュリティー上の理由から上書きされたくないので。

   def user_params
     params.require(:user).permit(:name, :email, :password, :password_confirmatin)
   end

   #current_userがあるとlogged_in_userで保証されているので
   def right_user
     @user = User.find(params[:id])
     redirect_to root_url unless current_user?(@user)
   end

   def admin_user
     redirect_to(root_url) unless current_user.admin?
   end
end
