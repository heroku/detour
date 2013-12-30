require "spec_helper"

describe "counting flaggable flags" do
  let!(:flag) { create :flag_in_flag }

  before do
    visit "/detour/flags/users"
  end

  it "displays the defined groups" do
    within "tr#feature_#{flag.feature.id} td.flag-in-count" do
      page.should have_content 1
    end
  end
end

describe "listing flag_in_flags" do
  let!(:flag) { create :flag_in_flag }

  before do
    User.instance_variable_set "@detour_flaggable_find_by", :email
    visit "/detour/flag-ins/#{flag.feature.name}/users"
  end

  it "displays the flagged-in model's find-by" do
    page.should have_content flag.flaggable.email
  end
end

describe "creating flag_in_flags", js: true do
  let(:user) { create :user }
  let!(:feature) { create :feature }

  before do
    User.instance_variable_set "@detour_flaggable_find_by", :email
    visit "/detour/flag-ins/#{feature.name}/users"
    page.find("[data-target='#create-flag-in']").click
  end

  context "when successful" do
    before do
      fill_in "ids", with: user.email
      click_button "Create Flag-in"
    end

    it "displays a success message" do
      page.should have_content "User #{user.email} has been flagged in to #{feature.name}"
    end

    it "creates the flag" do
      feature.users_flag_ins.first.flaggable.should eq user
    end

    it "renders the new flag-in" do
      within "table" do
        page.should have_content user.email
      end
    end
  end

  context "when unsuccessful" do
    before do
      fill_in "ids", with: "foo"
      click_button "Create Flag-in"
    end

    it "displays error messages" do
      page.should have_content "User foo could not be found"
    end
  end
end

describe "destroying flag_in_flags", js: true do
  let!(:flag) { create :flag_in_flag }

  before do
    visit "/detour/flag-ins/#{flag.feature.name}/users"
    page.find(".delete-flag").click
    click_link "Delete Flag-in"
  end

  it "displays a flash message" do
    page.should have_content "#{flag.feature.name} flag-in for User #{flag.flaggable.send flag.flaggable_type.constantize.detour_flaggable_find_by} has been deleted."
  end

  it "destroys the flag-in" do
    expect { flag.reload }.to raise_error ActiveRecord::RecordNotFound
  end


  it "removes the flag from the list" do
    page.should_not have_content flag.flaggable.email
  end
end
