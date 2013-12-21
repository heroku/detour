require "spec_helper"

describe Detour::FlagInFlagsController do
  routes { Detour::Engine.routes }

  describe "GET #index" do
    let(:flag) { create :flag_in_flag }

    before do
      get :index, feature_name: flag.feature.name, flaggable_type: "users"
    end

    it "assigns the flag-in flags" do
      assigns(:flags).should eq [flag]
    end

    it "renders the index template" do
      response.should render_template :index
    end
  end

  describe "DELETE #destroy" do
    let(:flag) { create :flag_in_flag }

    before do
      delete :destroy, feature_name: flag.feature.name, flaggable_type: "users", id: flag.id
    end

    it "destroys the flag" do
      expect { flag.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it "sets a flash message" do
      flash[:notice].should eq "#{flag.feature.name} flag-in for User #{flag.flaggable.id} has been deleted."
    end

    it "redirects to the flag-ins index" do
      response.should redirect_to flag_in_flags_path flag.feature.name, "users"
    end
  end
end
