require "spec_helper"

describe Detour::DatabaseGroupFlag do
  it { should validate_presence_of :group_id }
  it { should validate_presence_of :flaggable_type }
  it { should validate_uniqueness_of(:feature_id).scoped_to(:group_id) }

  it { should allow_mass_assignment_of :group_id }

  it { should belong_to :group }
  it { should have_many(:memberships).through(:group) }
end
