require "spec_helper"

describe ActiveRecord::Rollout::Flaggable do
  subject { User.new }
  it { should have_many :flags }
  it { should have_many :rollouts }
end
