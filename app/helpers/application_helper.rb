module ApplicationHelper
  #Railsのビューでは膨大な組み込み関数を使用することができるが、それに加えて新しい関数を作成することもできる。この関数はヘルパーと呼ばれる。

  #ページごとの完全なタイトルを返す。
  def full_title(page_title)
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      "#{base_title}|#{page_title}"
    end
  end
end
