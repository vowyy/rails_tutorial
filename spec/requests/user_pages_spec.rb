require 'spec_helper'

describe "User pages" do

    subject { page }
    # ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    # subject {}とは？
    # ブロック内の評価結果が it 内のshouldのレシーバとなる。
    # 本例テストのレシーバ（主語）はどちらもpageになるので、subjectとして括ることが出来る。
    # ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    # pageとは？
    # レスポンスがHTMLである場合、その内容を本メソッドで取得できる。
    # これはCapybaraの機能のひとつ。
    # ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    describe "index" do

        before do
          sign_in FactoryGirl.create(:user)
          FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
          FactoryGirl.create(:user, name: "Ben", email: "ben@example.com")
          visit users_path
        end

        it { should have_title('All users') }
        it { should have_content('All users') }

        it "should list each user" do
          User.all.each do |user|
            expect(page).to have_selector('li', text: user.name)
            #?????????
          end
        end

        #ページネーションのテスト
        describe "pagination" do

          before(:all) { 30.times { FactoryGirl.create(:user) } }
          after(:all)  { User.delete_all }

          it { should have_selector('div.pagination') }

          it "should list each user" do
            # User.all配列がUser.paginate(page: 1)に置き換えられていることに注目。コントローラーもかんな感じになっている。
            User.paginate(page: 1).each do |user|
              expect(page).to have_selector('li', text: user.name)
            end
          end
        end

        describe "delete links" do

          it { should_not have_link('delete') }

          describe "as an admin user" do
            let(:admin) { FactoryGirl.create(:admin) }
            before do
              sign_in admin
              visit users_path
            end

            it { should have_link('delete', href: user_path(User.first)) }

            it "should be able to delete another user" do
              expect do
                click_link('delete', match: :first)
                #match: :firstという記述があります。これは、どの削除リンクをクリックするかは問わないことをCapybaraに伝える
              end.to change(User, :count).by(-1)
              #expect記法のブロックバージョン
            end
            it { should_not have_link('delete', href: user_path(admin)) }
          end
        end
    end
ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
   describe "show" do
      # 必要なUserモデルオブジェクトを作成する.そのためにUser.createするよりユーザーのファクトリー (factory) を使用する。
      # letコマンドとFactory GirlのFactoryGirlメソッドを使ってUserのファクトリーを作成することができる
      let(:user) { FactoryGirl.create(:user) }
      #userのshowページで投稿を表示するので以下を作る。
      let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo")}
      let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar")}
      before { visit user_path(user) }

      it { should have_content(user.name) }
      it { should have_title(user.name) }

      #作成したmicropostがあるか
      describe "microposts" do
       it { should have_content(m1.content) }
       it { should have_content(m2.content) }
       it { should have_content(user.microposts.count) }
      end



      #Follow/Unfollowボタンをテストする
      describe "follow/unfollow buttons" do
        let(:other_user) { FactoryGirl.create(:user) }
        before { sign_in user }

        #followボタンを押すと......
        describe "following a user" do
          before { visit user_path(other_user) }

          it "should increment the followed user count" do
            expect do
              click_button "Follow"
            end.to change(user.followed_users, :count).by(1)
          end

          it "should increment the other user's followers count" do
            expect do
              click_button "Follow"
            end.to change(other_user.followers, :count).by(1)
          end

          describe "toggling the button" do
            before { click_button "Follow" }
            it { should have_xpath("//input[@value='Unfollow']") }
            # HTML5を含むXMLドキュメントを自在にナビゲートすることのできる、極めて高度かつパワフルなテクニック
          end
        end


　　　　　#unfollowボタンを押すと........
        describe "unfollowing a user" do
          before do
            user.follow(other_user)
            visit user_path(other_user)
          end

          it "should decrement the followed user count" do
            expect do
              click_button "Unfollow"
            end.to change(user.followed_users, :count).by(-1)
          end

          it "should decrement the other user's followers count" do
            expect do
              click_button "Unfollow"
            end.to change(other_user.followers, :count).by(-1)
          end

          describe "toggling the button" do
            before { click_button "Unfollow" }
            it { should have_xpath("//input[@value='Follow']") }
          end
      end
    end

ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー


　　#ただ単にサインアップベー時に行き期待した文字があるかテスト
    describe "new" do
      before { visit signup_path }

      it { should have_content('Sign up') }
      it { should have_title(full_title('Sign up')) }
    end



    # 正しくないユーザー登録情報と正しいユーザー登録情報を与えたときに、期待どおりに動作することを確認するテストの作成。
    describe "signup_path" do

          before { visit signup_path }

          let(:submit) { "Create my account" }
      　　 #<input type="submit" name="commit" value="Create my account" class="btn btn-primary" data-disable-with="Create my account">

          #ユーザー登録ページをブラウザで表示し、ユーザー登録情報に何も入力しないまま送信する操作 (無効な操作) と同等
          describe "with invalid information" do
            it "should not create a user" do
              expect { click_button submit }.not_to change(User, :count)
              #無効なデータを送信した場合、ユーザーのカウントが変わらないことが期待される。
              # 以下同義
              #initial = User.count
              #click_button "Create my account"
              #final = User.count
              #expect(initial).to eq final
            end

            #エラーメッセージテスト
            describe "after submission" do
              before { click_button submit }

              it { should have_title('Sign up') }
              it { should have_content('error')}
            end
          end

          #ユーザー登録ボタンを押したときに期待どおりに動作すること、ユーザー情報が有効な場合にはユーザーが新規作成され、無効な場合にはユーザーが作成されないことを確認する
          describe "with valid information" do
            before do
             fill_in "Name",         with: "Example User"
             fill_in "Email",        with: "user@example.com"
             fill_in "Password",     with: "foobar"
             fill_in "Confirmation", with: "foobar"
            end

            it "should create a user" do
              expect { click_button submit }.to change(User, :count).by(1)
              #有効なデータを送信した場合には、ユーザーのカウントが1つ増えることが期待される。
            end

            describe "after saving the user" do
              before { click_button submit }
              let(:user) { User.find_by(email: 'user@example.com')}

              it { should have_title(user.name) }
              it { should have_selector('div.alert.alert-success', text: 'Welcome') }
              #特定のHTMLタグが存在しているかどうかをテスト
            end
      end


ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

      describe "edit" do
            let(:user) {FactoriGirl.create(:user)}
            before　do
              login user
              visit_edit_path(user)
            end

            describe "page" do
              it {should have_content("Update your profile")}
              it { should have_title("Edit user") }
              it { should have_link('change', href: 'http://gravatar.com/emails') }
            end


            descirbe "with invalid information" do

              before do
               fill_in "Name",         with: ""
               fill_in "Email",        with: ""
              end
              before { click_button "Save changes"}

              it {should have_content('error')}
            end

            describe "with valid information" do

              let(:new_name)  { "New Name" }
              let(:new_email) { "new@example.com" }
              before do
                fill_in "Name",             with: new_name
                fill_in "Email",            with: new_email
                fill_in "Password",         with: user.password
                fill_in "Confirm Password", with: user.password
                click_button "Save changes"
              end

              it { should have_title(new_name) }
              it { should have_selector('div.alert.alert-success') }
              it { should have_link('Sign out', href: signout_path) }
              specify { expect(user.reload.name).to  eq new_name }
              specify { expect(user.reload.email).to eq new_email }
              #user.reloadを使用してテストデータベースからuser変数に再度読み込みが行われ、ユーザーの新しい名前とメールアドレスが新しい値と一致するかどうかが確認。
            end
      end
#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
　　　 describe "following/followers page" do
　　　   let(:user) { FactoryGirl.create(:user) }
        let(:other_user) { FactoryGirl.create(:user)}
        before { user.follow(other_user) }

        describe "followed users" do
          before do
            sign_in user
            visit following_user_path(user)
          end

          it { should have_title(full_title('Following')) }
          it { should have_selector('h3', text: 'Following') }
          it { should have_link(other_user.name, href: user_path(other_user)) }
        end

        describe "followers" do
          before do
            sign_in other_user
            visit followers_user_path(other_user)
          end

          it { should have_title(full_title('Followers')) }
          it { should have_selector('h3', text: 'Followers') }
          it { should have_link(user.name, href: user_path(user)) }
        end
    end
  end
