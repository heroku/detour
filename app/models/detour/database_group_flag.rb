class Detour::DatabaseGroupFlag < Detour::Flag
  include Detour::Concerns::Keepable

  validates_presence_of   :group_id
  validates_presence_of   :flaggable_type
  validates_uniqueness_of :feature_id, scope: :group_id

  attr_accessible :group_id

  belongs_to :group
  has_many   :memberships, through: :group

  def members
    flaggable_class.joins(%Q{INNER JOIN "detour_memberships" ON "#{flaggable_class.table_name}"."id" = "detour_memberships"."member_id"}).where(detour_memberships: { group_id: group.id })
  end

  def group_name
    group.name
  end

  def group_type
    "database"
  end

  private

  def flaggable_class
    flaggable_type.constantize
  end
end
