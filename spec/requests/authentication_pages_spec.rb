require 'spec_helper'

describe "Authentication" do
  subject { page }


  #セッションのnewアクションとビューをテスト
  describe "login page" do
    before { visit login_path }

    it { should have_content('Log in')}
    it { should have_title('Log in')}
  end

  #ログイン失敗時のテスト
  describe "login" do
    before { visit login_path }

    decribe "with invalid information" do
      before { click_button 'Log in' }

      it { should have_title('Log in')}
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      # flash[:danger]が消えない問題。
      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    #ログイン成功時のテスト
    describe "with valid information" do
      let(:user) {FactoryGirl.create(:user)}
      before do
        fill_in "Email",    with: user.email.upcase
        fill_in "Password", with: user.password
        click_button "Lon in"
      end
      # やっていること
      # FactoryGirlでfactories.rbに定義してある:userをテスト用のデータベースに保存し、letでuser変数に入れる。
      # before内で正しいEmailとPasswordをfill_inして送信する。

      it { should have_title('user.name')} # 成功後、ログインしたuserの名前がtitleにあるか？
      #以下リンクがサイト内にあるか？
      it { should have_link('Profile', href: user_path(user))}
      it { should have_link('Users', href: users_path) }  #indexを追加したのでこのテストを追加。
      it { should have_link('Settings',　href: edit_user_path(user))} # edit機能を追加したのでこの行を追加。
      it { should have_link('Log out'), href: logout_path}
      it { should_not have_link('Sign in', href: signin_path) }
    end

ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    describe "authorization" do
　　　　
        #ログインしていないユーザー
        describe "for non-logged-in users" do



            let(:user) { FactoryGirl.create(:user) }

            #フレンドリーフォワーディングのテスト。
            describe "when attempting to visit a protected page" do
              before do
                visit edit_user_path(user)
                fill_in "Email",    with: user.email
                fill_in "Password", with: user.password
                click_button "Sign in"
              end

            describe "after signing in" do
              it "should render the desired protected page" do
                expect(page).to have_title('Edit user')
              end
            end



            # ログインしていないユーザーが各アクションのページに行こうとした結果。
            describe "in the Users controller" do

              describe "visiting the edit page" do
                before { visit edit_user_path(user) }
                it { should have_title('Log in') }
              end

              describe "submitting to the update action" do
                before { patch user_path(user) }#訪れるページがないので before { visit update_user_path(user)}みたいにはできない。
                # ブラウザはupdateアクションを直接表示することができないからです。(update.html.erbはない)ブラウザは、編集フォームを送信することでしか間接的にそのアクションに到達することしかできないので
                # (訳注: updateは純粋に更新処理を行うアクションであって、そこで何かを表示するわけではないので)、 Capybaraでは対応できません。
                # updateアクション自体をテストするにはリクエストを直接発行する以外に方法がありません
                specify { expect(response).to redirect_to(log_path) }
              end

              describe "visiting the user index" do
                before { visit users_path }
                it { should have_title('Sign in') }
              end

              describe "visiting the following page" do
                before { visit following_user_path(user) }
                it { should have_title('Sign in') }
              end

              describe "visiting the followers page" do
                before { visit followers_user_path(user) }
                it { should have_title('Sign in') }
              end
            end



              describe "in the Microposts controller" do
                  # それぞれのマイクロポストアクションのレベルで動作

                  describe "submitting to the create action" do
                    before { post microposts_path }
                    specify { expect(response).to redirect_to(login_path) }
                  end

                  describe "submitting to the destroy action" do
                    before { delete micropost_path(FactoryGirl.create(:micropost)) }
                    specify { expect(response).to redirect_to(login_path) }
                  end
              end

              describre "in the Relationships controller"
               decribe "submitting to the create action" do
                 before { post relationships_path
                 specify { expect(response).to redirect_to(signin_path)}
               end

               describe "submitting to the destory action" do
                 before { delete relationships_path(1) }
                 specify { expect(response).to redirect_to(signin_path)}
               end
          　end
        end
        end

〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜

  　　　　#ログインはしているが正しいユーザーではない場合。
        descirbe "as worng user" do
            let(:user1) { FactoryGirl.create(:user) }
            let(:user2) { FactoryGirl.create(:user, email: "wrong@example.com") }
            before { sign_in user, no_capybara: true }

            describe "submitting a GET request to the Users#edit action" do
              before { get edit_user_path(user2) }
              specify { expect(response.body).not_to match(full_title('Edit user')) }
              specify { expect(response).to redirect_to(root_url) }
            end

            describe "submitting a PATCH request to the Users#update action" do
              before { patch user_path(user2) }
              specify { expect(response).to redirect_to(root_path) }
            end

            #adminではないユーザーがdestroyアクションを飛ばす。
            describe "as non-admin user" do
               let(:user) { FactoryGirl.create(:user) }
               let(:non_admin) { FactoryGirl.create(:user) }

               before { sign_in non_admin, no_capybara: true }

               describe "submitting a DELETE request to the Users#destroy action" do
                 before { delete user_path(user) }
                 specify { expect(response).to redirect_to(root_path) }
               end
             end
  　　　　end
  #ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

  　
    end
  end
end
end
