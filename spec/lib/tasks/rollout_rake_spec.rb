require "spec_helper"

describe "rollout:activate_record" do
  include_context "rake"

  let(:user) { User.create(name: "foo") }

  it "activates the feature for the record" do
    ActiveRecord::Rollout::Feature.should_receive(:add_record_to_feature).with(user, "foo")
    subject.invoke("foo", "User", user.id.to_s)
  end
end

describe "rollout:deactivate_record" do
  include_context "rake"

  let(:user) { User.create(name: "foo") }

  it "deactivates the feature for the record" do
    ActiveRecord::Rollout::Feature.should_receive(:remove_record_from_feature).with(user, "foo")
    subject.invoke("foo", "User", user.id.to_s)
  end
end

describe "rollout:opt_out_record" do
  include_context "rake"

  let(:user) { User.create(name: "foo") }

  it "deactivates the feature for the record" do
    ActiveRecord::Rollout::Feature.should_receive(:opt_record_out_of_feature).with(user, "foo")
    subject.invoke("foo", "User", user.id.to_s)
  end
end

describe "rollout:un_opt_out_record" do
  include_context "rake"

  let(:user) { User.create(name: "foo") }

  it "deactivates the feature for the record" do
    ActiveRecord::Rollout::Feature.should_receive(:un_opt_record_out_of_feature).with(user, "foo")
    subject.invoke("foo", "User", user.id.to_s)
  end
end

describe "rollout:activate_group" do
  include_context "rake"

  it "activates the feature for the group" do
    ActiveRecord::Rollout::Feature.should_receive(:add_group_to_feature).with("User", "admins", "foo")
    subject.invoke("foo", "User", "admins")
  end
end

describe "rollout:deactivate_group" do
  include_context "rake"

  it "deactivates the feature for the group" do
    ActiveRecord::Rollout::Feature.should_receive(:remove_group_from_feature).with("User", "admins", "foo")
    subject.invoke("foo", "User", "admins")
  end
end

describe "rollout:activate_percentage" do
  include_context "rake"

  it "activates the feature for the percentage" do
    ActiveRecord::Rollout::Feature.should_receive(:add_percentage_to_feature).with("User", 50, "foo")
    subject.invoke("foo", "User", "50")
  end
end

describe "rollout:deactivate_percentage" do
  include_context "rake"

  it "deactivates the feature for the percentage" do
    ActiveRecord::Rollout::Feature.should_receive(:remove_percentage_from_feature).with("User", "foo")
    subject.invoke("foo", "User")
  end
end
