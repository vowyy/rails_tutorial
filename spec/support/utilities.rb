# テスト用のヘルパーメソッド

def login(user, options={})
  if optons[:no_capybara]
    remember_token = User.new_token
    user.update_attribute(:remember_digest, User.digest(:remember_token))
    cookies[:remember_token] = remember_token
    #テスト用のcookiesオブジェクトは実際のcookiesオブジェクトを完全にシミュレートできているわけではない。cookies.permanentメソッドはテスト内で動かすことはできない
  else
    visit login_path
    fill_in "Email",  with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
  end
end
