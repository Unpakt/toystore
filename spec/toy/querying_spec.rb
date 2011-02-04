require 'helper'

describe Toy::Querying do
  uses_constants('User', 'Game')

  before do
    User.attribute :name, String
  end

  describe ".get" do
    it "returns document if found" do
      john = User.create(:name => 'John')
      User.get(john.id).name.should == 'John'
    end

    it "returns nil if not found" do
      User.get('1').should be_nil
    end
  end

  describe ".get!" do
    it "returns document if found" do
      john = User.create(:name => 'John')
      User.get!(john.id).name.should == 'John'
    end

    it "raises not found exception if not found" do
      lambda {
        User.get!('1')
      }.should raise_error(Toy::NotFound, 'Could not find document with id: "1"')
    end
  end

  describe ".get_multi" do
    it "returns array of documents" do
      john  = User.create(:name => 'John')
      steve = User.create(:name => 'Steve')
      User.get_multi(john.id, steve.id).should == [john, steve]
    end
  end

  describe ".get_or_new" do
    it "returns found" do
      user = User.create
      User.get_or_new(user.id).should == user
    end

    it "creates new with id set if not found" do
      user = User.get_or_new('foo')
      user.should be_instance_of(User)
      user.id.should == 'foo'
    end
  end

  describe ".get_or_create" do
    it "returns found" do
      user = User.create
      User.get_or_create(user.id).should == user
    end

    it "creates new with id set if not found" do
      user = User.get_or_create('foo')
      user.should be_instance_of(User)
      user.id.should == 'foo'
    end
  end

  describe ".key?" do
    it "returns true if key exists" do
      user = User.create(:name => 'John')
      User.key?(user.id).should be_true
    end

    it "returns false if key does not exist" do
      User.key?('taco:bell:tacos').should be_false
    end
  end

  describe ".has_key?" do
    it "returns true if key exists" do
      user = User.create(:name => 'John')
      User.has_key?(user.id).should be_true
    end

    it "returns false if key does not exist" do
      User.has_key?('taco:bell:tacos').should be_false
    end
  end

  describe ".load (with hash)" do
    before    { @doc = User.load('1', :name => 'John') }
    let(:doc) { @doc }

    it "returns instance" do
      doc.should be_instance_of(User)
    end

    it "marks object as persisted" do
      doc.should be_persisted
    end

    it "decodes the object" do
      doc.name.should == 'John'
    end
  end

  describe "with cache store" do
    before do
      @cache  = User.cache(:memory, {})
      @memory = User.store(:memory, {})
      @user   = User.create
      Toy.identity_map.clear # ensure we are just working with database
    end

    let(:cache)   { @cache }
    let(:memory)  { @memory }
    let(:user)    { @user }

    describe "not found in cache or store" do
      before do
        cache.delete(user.store_key)
        memory.delete(user.store_key)
      end

      it "returns nil" do
        User.get('foo').should be_nil
      end
    end

    describe "not found in cache" do
      before do
        cache.delete(user.store_key)
      end

      it "returns from store" do
        User.get(user.id).should == user
      end

      it "populates cache" do
        cache.key?(user.store_key).should be_false
        User.get(user.id)
        cache.key?(user.store_key).should be_true
      end
    end

    describe "found in cache" do
      before do
        cache.key?(user.store_key).should be_true
      end

      it "returns from cache" do
        cache.should_receive(:read).with(user.store_key).and_return(user.persisted_attributes)
        User.get(user.id)
      end

      it "does not hit store" do
        memory.should_not_receive(:read)
        User.get(user.id)
      end
    end
  end
end