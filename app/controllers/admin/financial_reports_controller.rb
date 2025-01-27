class Admin::FinancialReportsController < Admin::BaseController
  before_action :load_organisation
  before_action :load_financial_report, only: %i[edit update destroy]
  layout :get_layout

  def index
    render_design_system(:index, :legacy_index)
  end

  def edit
    render_design_system(:edit, :legacy_edit)
  end

  def new
    @financial_report = @organisation.financial_reports.build(year: Time.zone.now.year)
    render_design_system(:new, :legacy_new)
  end

  def create
    @financial_report = @organisation.financial_reports.build(financial_report_params)
    if @financial_report.save
      redirect_to [:admin, @organisation, FinancialReport], notice: "Created Financial Report"
    else
      render_design_system(:new, :legacy_new)
    end
  end

  def update
    if @financial_report.update(financial_report_params)
      redirect_to [:admin, @organisation, FinancialReport], notice: "Updated Financial Report"
    else
      render_design_system(:edit, :legacy_edit)
    end
  end

  def destroy
    @financial_report.destroy!
    redirect_to admin_organisation_financial_reports_path(@organisation), notice: "Deleted Successfully"
  end

  def confirm_destroy
    @financial_report = @organisation.financial_reports.find(params[:id])
  end

private

  def get_layout
    design_system_actions = []
    design_system_actions += %w[index new create edit update confirm_destroy] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def load_financial_report
    @financial_report = @organisation.financial_reports.find(params[:id])
  end

  def load_organisation
    @organisation = Organisation.friendly.find(params[:organisation_id])
  end

  def financial_report_params
    params.require(:financial_report).permit(:year, :spending, :funding)
  end
end
