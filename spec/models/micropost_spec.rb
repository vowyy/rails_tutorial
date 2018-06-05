require 'rails_helper'

describe Micropost do

  let(:user) { Factory.Girl.create(:user)}
  before { @micropost = user.microposts.build(content: "fack off") }

  subject @micropost

  it { should respond_to(:content) }
  it { should respond_to(:user_id) } # idだけを返す。
  it { should respond_to(:user) } # 紐ずいたユーザーのレコードを返す。
  its(:user) { should eq user }

    #新しいマイクロポストに対する検証をテストする。
    describe "when user_id is not present" do
      before @micropost.user_id = nil
      it { should_not be_valid }
    end

    describe "with blank content" do
      before @micropost.content = ""
      it { should_not be_valid }
    end

    describe "with content that is too long" do
      before @micropost.content = "a" * 141
      it { should_not be_valid}
    end
    


end
