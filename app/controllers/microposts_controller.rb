class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :deletable_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    # before_actionのlogged_in_userでcurrent_userは使えると言う保証がある。
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
      # redirect_to はもう一度リクエストを飛ばす => homeアクションを通り@feed_itemsをもう一度取得した上でroot_url(home.html.erb)へ行く。
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      # render はもう一度リクエストを飛ばすようなことはしない。=> homeアクションを経由しないで元あったものを再描画するだけ
      # なので@feed_itemsって何？となる。上で宣言してある@micropostしかわからない。
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
   #deletable_userで@micropostを宣言しているのでここで使える。
   flash[:success] = "Micropost deleted"
   redirect_to request.referrer || root_url
   #現段階でmicropostの削除をできるベージがhome.html.erbとshow.html.erbの二箇所なのでどっちからdeleteリクエストを贈られたかによって返すベー寺を変える。
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :picture)
    #user_idを入れる必要がない。
  end

  def deletable_user
    # DELETE /micropost/:id
    @micropost = current_user.microposts.find_by(id: params[:id])
    #　自分のmicropostsの集合の中に消そうとしているidの投稿があれば消せる。
    redirect_to root_url if @micropost.nil?
  end
end
