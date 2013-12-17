require "spec_helper"

describe "group rollouts" do
  let(:user) { User.create(name: "foo") }
  let(:feature) { Detour::Feature.create(name: "foo") }
  let!(:flag) { feature.group_flags.create(flaggable_type: "User", group_name: "foo_users") }

  describe "creating a group rollout" do
    before do
      Detour::Feature.define_user_group "foo_users" do |user|
        user.name == "foo"
      end
    end

    it "sets the feature on the user" do
      feature.match_groups?(user).should be_true
    end
  end
end

