class StaticPagesController < ApplicationController

#StaticPagesコントローラはget一般的なRESTアクションに対応していない。
#静的なページの集合に対しては、適切なアクションと言える。
#RESTアーキテクチャは、あらゆる問題に対して最適な解決方法であるとは限らないということ。

  def home
    if logged_in?
      @micropost = current_user.microposts.build # if logged_in?
      @feed_items = current_user.feed.paginate(page: params[:page])
      #自分が投稿した物の集合ということは数が膨大になる可能性があるのでページネーションをかける。
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
