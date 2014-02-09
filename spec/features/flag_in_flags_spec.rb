require "spec_helper"

describe "counting flag-in flags" do
  let!(:flag) { create :flag_in_flag }

  context "when the feature is persisted" do
    before do
      visit "/detour/flags/users"
    end

    it "displays the flag-in count" do
      within "tr#feature_#{flag.feature.id} td.flag-in-count" do
        page.should have_link "1", href: "/detour/flag-ins/#{flag.feature.name}/users"
      end
    end
  end

  context "when the feature is not persisted" do
    before do
      flag.feature.destroy
      Detour::Feature.stub(:with_lines) { [flag.feature] }
      visit "/detour/flags/users"
    end

    it "does not display a link" do
      page.should_not have_link "1", href: "/detour/opt-outs/#{flag.feature.name}/users"
    end

    it "displays a non-link 0" do
      within "tr#feature_#{flag.feature.id} td.flag-in-count" do
        page.should have_text "0"
      end
    end
  end
end

describe "counting opt-out flags" do
  let!(:flag) { create :opt_out_flag }

  context "when the feature is persisted" do
    before do
      visit "/detour/flags/users"
    end

    it "displays the opt-out count" do
      within "tr#feature_#{flag.feature.id} td.opt-out-count" do
        page.should have_link "1", href: "/detour/opt-outs/#{flag.feature.name}/users"
      end
    end
  end

  context "when the feature is not persisted" do
    before do
      flag.feature.destroy
      Detour::Feature.stub(:with_lines) { [flag.feature] }
      visit "/detour/flags/users"
    end

    it "does not display a link" do
      page.should_not have_link "1", href: "/detour/opt-outs/#{flag.feature.name}/users"
    end

    it "displays a non-link 0" do
      within "tr#feature_#{flag.feature.id} td.opt-out-count" do
        page.should have_text "0"
      end
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
    page.find("input[type='text'][disabled]").value.should eq flag.flaggable.email
  end
end

describe "creating a flag-in", js: true do
  let(:user) { create :user }
  let!(:feature) { create :feature }

  before do
    User.instance_variable_set "@detour_flaggable_find_by", :email
    visit "/detour/flag-ins/#{feature.name}/users"
    page.find(".add-fields").click
  end

  context "when successful" do
    before do
      name = page.find("##{page.all("label")[-2][:for]}")[:name]
      fill_in name, with: user.email
      click_button "Update Flag-ins"
    end

    it "displays a flash message" do
      page.should have_content "Your flag-ins have been updated"
    end

    it "shows the newly added flag-in" do
      page.find("input[type='text'][disabled]").value.should eq user.email
    end
  end

  context "when unsuccessful" do
    before do
      click_button "Update Flag-in"
    end

    it "displays error messages" do
      page.should have_content "Users flag ins user \"\" could not be found"
    end
  end
end

describe "destroying flag-ins", js: true do
  let!(:flag) { create :flag_in_flag }

  before do
    visit "/detour/flag-ins/#{flag.feature.name}/users"
    name = page.find("##{page.all("label").last[:for]}")[:name]
    check name
    click_button "Update Flag-in"
  end

  it "removes the flag from the list" do
    page.should_not have_selector "label[for='feature_flag_in_flags_attributes_0_flaggable_key']"
  end
end
