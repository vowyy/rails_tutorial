require 'rails_helper'

# $ bundle exec rake db:test:prepare
# テスト環境用データベースを用意
# 開発データベースのデータモデルdb/development.sqlite3がテストデータベースdb/test.sqlite3に反映されるようにするもの

describe User do

    before do
      @user = User.new(name: "Example", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
    end
    # beforeブロックは前処理用で、各サンプルが実行される前にそのブロックの中のコードを実行します。
    subject{ @user } # page変数を扱ったときと同じように、@userをテストサンプルのデフォルトのsubjectとして設定します。

    it { should respond_to(:name)}
    it { should respond_to(:email)}
    it { should respond_to(:password_digest)} # password_digestカラムがあることを確認するテスト。新たなカラムをデータベースに追加したのでbundle exec rake db:test:prepareをしないとエラーになる。
    it { should respond_to(:password)}
    it { should respond_to(:password_confirmation)}
    it { should respond_to(:authenticate)}
    it { should respond_to(:admin)}

    it { should respond_to(:microposts)}
    # Userオブジェクトがname属性を持っていない場合、beforeブロックの中で例外を投げるので、一見、これらのテストが冗長に思えるかもしれない。が、
    # これらのテストを追加することで、user.nameやuser.emailが正しく動作することを保証できる
    # シンボルを1つ引数として受け取り、そのシンボルが表すメソッドまたは属性に対して、オブジェクトが応答する場合はtrueを返し、応答しない場合はfalseを返す

    it { should respond_to(:feed) }
    it { should respond_to(:active_relationships) }
    it { should respond_to(:following) }
    it { should respond_to(:passive_relationhips) }
    it { should respond_to(:followers)}

    it { should be_valid }

    # まず@userというsubjectが有効かどうかを確認。
    # valid?というメソッドがあるので,それに対応するbe_validというテストメソッドが自動的に存在。
    # 例えば、foo?というメソッドがあれば,be_fooというテストメソッドが存在。

    it { should_not be_admin}
    #admin?メソッドを投げる。今はまだfalse

    #admin属性に対するテスト。
    describe "with admin attribute set to 'true'" do
      before do
        @user.save!
        @user.toggle!(:admin)
        #toggle!メソッドを使用して admin属性の状態をfalseからtrueに反転
      end

      it { should be_admin }
    end

    #ユーザーのnameに無効な値 (blank) をテストして確認。
    describe "when name is not present" do
      before { @user.name = " "}
      it { should_not be_valid }
    end


    #ユーザーのname,emailに無効な値 (blank) をテストして確認。
    describe "when email is not present" do
      before { @user.email = " "}
      it { should_not be_valid }
    end


    #ユーザーのname,emailの長さをテストして確認。
    describe "when name is too long" do
      before { @user.name = "a" * 51}
      it { should_not be_valid }
    end


    describe "when email is too long" do
      before { @user.email = "a" * 256 }
      it { should_not be_valid}
    end


    #ダメなメールアドレスフォーマットの検証テスト
    describe "when email format is invalid" do
      it "should be invalid" do
        addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                       foo@bar_baz.com foo@bar+baz.com]
        addresses.each do |invalid_address|
          @user.email = invalid_address
          expect(@user).not_to be_valid
        end
      end
    end


  　#大丈夫なメールアドレスフォーマットの検証テスト
    describe "when email format is valid" do
      it "should be valid" do
        addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
        addresses.each do |valid_address|
          @user.email = valid_address
          expect(@user).to be_valid
        end
      end
    end


    #重複するメールアドレスの拒否のテスト
    describe "when email address is already taken" do
      before do
        user_with_same_email = @user.dup
        user_with_same_email.email = @user.email.upcase # userのemailを区別しないためのテスト。これで下のbe_validがtrueになったら困る。
        user_with_same_email.save
      end

      it { should_not be_valid}
    end


    #パスワードの存在確認テスト
    describe "when password is not present" do
      before do
        @user = User.new(name: "Example User", email: "user@example.com", password: " ", password_confirmation: " ")
      end

      it { should_not be_valid}
    end


    #パスワードの長さをテスト
    describe "with a password that's too short" do
      before { @user.passoword = @user.password_confirmation =  "a" * 5 }
      it { should_not be_valid}
    end


    #パスワードとパスワードの一致確認をテスト
    describe "when password doesn't match confirmation" do
      before { @user.password_confirmatin = "missmatch"}
      it {should_not be_valid}
    end


    #ユーザー認証(authenticate)のテスト
    describe "return value of authenticate method" do

      before { @user.save } #subject(@user)をテスト用のデータベースに登録。find_byメソッドが使えるようになり、データベースのuserを検索できる。
      let(:found_user) { User.find_by(email: @user.email) } #found_user = User.find_by(email: @user.email)と同じ
      #これにより、この変数はテスト中すべてのbeforeまたはitブロックで利用できるようになる。


      #@userとfound_userのパスワードが一致する場合
      describe "with valid password" do
        it { should eq found_user.authenticate(@user.password) }#authenticateによって何が返ってくるか？
        # eqは、オブジェクト同士が同値であるかどうかを二重等号演算子==を使用して確認している。
        # なのでここではit(@user)と "found_user.authenticate(@user.password) }"によって帰ってくるオブジェクト(@user)が同じか調べる。
      end


      #@userとfound_userのパスワードが一致しない場合
      describe "with invalid password" do
        let(:user_for_invalid_password) { found_user.authenticate("invalid") }
        #user_for_invalid_passowordには"found_user.authenticate("invalid")"の結果(false)が入る。

        it { should_not eq user_for_invalid_password }
        specify { expect(user_for_invalid_password).to be_false }
        #specifyはitと同義であり、itを使用すると英語として不自然な場合にこれで代用することができる
      end
    end



ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    describe "micropost associatoins" do

      before { @user.save }

      let!(:older_micropost) do
        FactoruyGirl.create(:micropost, user: @user, created_at: 1.day.ago)
      end
      let!(:newer_micropost) do
        FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
      end


　　　　#　micropostの並び順のテスト
      it "should have the right microposts in the right order" do
        expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
      end

      # ユーザーを破棄するとマイクロポストも破棄されることをテスト
      it "should destroy associated microposts" do
        microposts = @user.microposts.to_a　
        @user.destroy
        expect(microposts).not_to be_empty
        #to_aメソッドがなかったら、ユーザーを削除したときにmicroposts変数に含まれているポストまで削除されてしまう
        #なので配列に一旦避難させる。
        # micropostsが空になってしまうため、上のテストに何を書いても動作しなくなってしまう
        microposts.each do |micropost|
          expect(Micropost.where(id: micropost.id)).to be_empty
          # whereメソッドは、レコードがない場合に空のオブジェクトを返すので多少テストが書きやすくなる
        end
      end


      # 今は、feedメソッドが自分のマイクロポストと他ユーザーのマイクロポストを含むことをテストする
      describe "status" do
        #自分がフォローしていないユーザーの投稿
        let(:unfollowed_post) do
          FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
        end
        let(:followed_user) { FactoryGirl.create(:user) }

        before do
          @user.follow(followed_user)
          3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
        end

        its(:feed) { should include(newer_micropost) }
        its(:feed) { should include(older_micropost) }
        its(:feed) { should_not include(unfollowed_post) }
        its(:feed) do
          followed_user.microposts.each do |micropost|
            should include(micropost)
          end
      end

    end
#ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

　describe "following" do
     let(:other_user) { FactoryGirl.create(:user) }
     before do
       @user.save
       @user.follow(other_user)
     end

     it { should be_following(other_user) } #following?のこと。上でフォローしたので。
     its(:following) { should include(other_user)}

     describe "followed_user" do
       subject { other_user }
       its(:followers) { should include(@usr)}
     end

     describe "and unfollowing"
       before { @user.unfollow(other_user) }
       its(:following) { should_not include(other_user)}
     end
  end
#end
