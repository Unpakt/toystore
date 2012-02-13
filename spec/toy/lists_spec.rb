require 'helper'

describe Toy::Lists do
  uses_constants('User', 'Game', 'Move')

  it "defaults lists to empty hash" do
    User.lists.should == {}
  end

  describe ".list?" do
    before do
      User.list(:games)
    end

    it "returns true if attribute (symbol)" do
      User.list?(:games).should be_true
    end

    it "returns true if attribute (string)" do
      User.list?('games').should be_true
    end

    it "returns false if not attribute" do
      User.list?(:foobar).should be_false
    end
  end

  describe "declaring a list" do
    describe "using conventions" do
      before do
        @list = User.list(:games)
      end

      it "knows about its lists" do
        User.lists[:games].should == Toy::List.new(User, :games)
      end

      it "returns list" do
        @list.should == Toy::List.new(User, :games)
      end
    end

    describe "with type" do
      before do
        @list = User.list(:active_games, Game)
      end
      let(:list) { @list }

      it "sets type" do
        list.type.should be(Game)
      end

      it "sets options to hash" do
        list.options.should be_instance_of(Hash)
      end
    end

    describe "with options" do
      before do
        @list = User.list(:games, :dependent => true)
      end
      let(:list) { @list }

      it "sets type" do
        list.type.should be(Game)
      end

      it "sets options" do
        list.options.should have_key(:dependent)
        list.options[:dependent].should be_true
      end
    end

    describe "with type and options" do
      before do
        @list = User.list(:active_games, Game, :dependent => true)
      end
      let(:list) { @list }

      it "sets type" do
        list.type.should be(Game)
      end

      it "sets options" do
        list.options.should have_key(:dependent)
        list.options[:dependent].should be_true
      end
    end
  end

  describe "#clone" do
    before do
      User.list(:games)

      @game = Game.create
      @user = User.create(:games  => [@game])
    end

    let(:game)  { @game }
    let(:user)  { @user }

    it "clones list id attributes" do
      user.clone.game_ids.should_not equal(user.game_ids)
    end

    it "clones the list" do
      user.clone.games.should_not equal(user.games)
    end
  end
end