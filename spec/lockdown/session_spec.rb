require File.join(File.dirname(__FILE__), %w[.. spec_helper])

class TestAController
  include Lockdown::Session
end

describe Lockdown::Session do
  before do
    @controller = TestAController.new

    @actions = %w(posts/index posts/show posts/new posts/edit posts/create posts/update posts/destroy)

    @session = {:access_rights => @actions}

    @controller.stub!(:session).and_return(@session)
  end

  describe "#nil_lockdown_values" do
    it "should nil access_rights" do
      @controller.nil_lockdown_values
      @session[:access_rights].should == nil
    end
  end

  describe "#current_user_access_in_group?" do
    it "should return true if current user is admin" do
      @actions = :all
      @session = {:access_rights => @actions}
      @controller.stub!(:session).and_return(@session)

      @controller.current_user_access_in_group?(:group).should == true
    end

    it "should return true if current_user has access" do
      user_groups = {:public_group => [:public_access]}
      hash  = {:public_access => ["posts/index", "posts/show"]}
      Lockdown::System.stub!(:permissions).and_return(hash)

      Lockdown::System.stub!(:user_groups).and_return(user_groups)
      @controller.current_user_access_in_group?(:public_group).should be_true
    end

    it "should return false if current_user has access" do
      user_groups = {:public_group => [:public_access]}
      hash  = {:public_access => ["books/edit", "books/update"]}
      Lockdown::System.stub!(:permissions).and_return(hash)

      Lockdown::System.stub!(:user_groups).and_return(user_groups)
      @controller.current_user_access_in_group?(:public_group).should be_false
    end
  end

  describe "#current_user_is_admin?" do
    it "should return true if access_rights == :all" do
      @actions = :all
      @session = {:access_rights => @actions}
      @controller.stub!(:session).and_return(@session)

      @controller.current_user_is_admin?.should == true
    end
  end

  describe "#add_lockdown_session_values" do
    it "should set the access_rights from the user list" do
      array  = ["posts/index", "posts/show"]
      Lockdown::System.stub!(:access_rights_for_user).and_return(array)
      @controller.add_lockdown_session_values(:user_object).
        should == array
    end
  end


  describe "#access_in_perm" do
    it "should return false if permissions nil" do
      Lockdown::System.stub!(:permissions).and_return({})
      @controller.access_in_perm?(:dummy).should be_false
    end

    it "should return true if permission found" do
      hash  = {:public => ["posts/index", "posts/show"]}
      Lockdown::System.stub!(:permissions).and_return(hash)
      @controller.access_in_perm?(:public).should be_true
    end
  end

  describe "#session_access_rights_include?" do
  end
end