module GovernmentsHelper
  def create_government(name:, start_date:, end_date:)
    visit admin_governments_path

    click_on "Create a government"

    fill_in "Name", with: name
    fill_in "Start date", with: start_date
    fill_in "End date", with: end_date

    click_on "Save"
  end

  def check_for_government(name:, start_date:, end_date:)
    visit admin_governments_path

    government = Government.find_by_name(name)

    within("#government_#{government.id}") do
      assert page.has_content?(name)
      assert page.has_content?(start_date)
      assert page.has_content?(end_date)
    end
  end
end

World(GovernmentsHelper)
