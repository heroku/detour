require "spec_helper"

describe "counting opt out flags" do
  let!(:flag) { create :opt_out_flag }

  before do
    visit "/detour/flags/users"
  end

  it "displays the defined groups" do
    within "tr#feature_#{flag.feature.id} td.opt-out-count" do
      page.should have_content 1
    end
  end
end

describe "listing opt_out_flags" do
  let!(:flag) { create :opt_out_flag }

  before do
    User.instance_variable_set "@detour_flaggable_find_by", :email
    visit "/detour/opt-outs/#{flag.feature.name}/users"
  end

  it "displays the correct header" do
    within "h1" do
      page.should have_content "Users opted out of #{flag.feature.name}"
    end
  end

  it "displays the opted-out model's find-by" do
    page.find("input[type='text'][disabled]").value.should eq flag.flaggable.email
  end
end

describe "creating a opt-out", js: true do
  let(:user) { create :user }
  let!(:feature) { create :feature }

  before do
    User.instance_variable_set "@detour_flaggable_find_by", :email
    visit "/detour/opt-outs/#{feature.name}/users"
    page.find(".add-fields").click
  end

  context "when successful" do
    before do
      name = page.find("##{page.all("label")[-2][:for]}")[:name]
      fill_in name, with: user.email
      click_button "Update Opt-outs"
    end

    it "displays a flash message" do
      page.should have_content "Your opt-outs have been updated"
    end

    it "shows the newly added opt-out" do
      page.find("input[type='text'][disabled]").value.should eq user.email
    end
  end

  context "when unsuccessful" do
    before do
      click_button "Update Opt-outs"
    end

    it "displays a correct error header" do
      within ".panel-danger .panel-heading" do
        page.should have_content "Whoops! There were some errors saving your opt-outs:"
      end
    end

    it "displays error messages" do
      page.should have_content "User \"\" could not be found"
    end
  end
end

describe "destroying opt-outs", js: true do
  let!(:flag) { create :opt_out_flag }

  before do
    visit "/detour/opt-outs/#{flag.feature.name}/users"
    name = page.find("##{page.all("label").last[:for]}")[:name]
    check name
    click_button "Update Opt-outs"
  end

  it "removes the flag from the list" do
    page.should_not have_selector "label[for='feature_opt_out_flags_attributes_0_flaggable_key']"
  end
end
