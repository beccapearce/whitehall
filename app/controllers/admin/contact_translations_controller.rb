class Admin::ContactTranslationsController < Admin::BaseController
  include TranslationControllerConcern
  layout :get_layout

  def index; end

  def edit
    render_design_system(:edit, :legacy_edit)
  end

private

  def get_layout
    design_system_actions = %w[confirm_destroy]
    design_system_actions += %w[edit index update] if preview_design_system?(next_release: false)
    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def create_redirect_path
    edit_admin_organisation_contact_translation_path(@contactable, @contact, id: translation_locale)
  end

  def update_redirect_path
    admin_organisation_contacts_path(@contactable)
  end

  def destroy_redirect_path
    admin_organisation_contacts_path(@contactable)
  end

  def load_translatable_item
    @contactable = Organisation.friendly.find(params[:organisation_id])
    @contact = @contactable.contacts.find(params[:contact_id])
  end

  def load_translated_models
    @translated_contact = LocalisedModel.new(@contact, translation_locale.code, [:contact_numbers])
    @english_contact = LocalisedModel.new(@contact, :en, [:contact_numbers])
  end

  def translated_item_name
    @contact.title
  end

  def translatable_item
    @translated_contact
  end

  def translation_params
    params.require(:contact).permit(
      :title,
      :comments,
      :recipient,
      :street_address,
      :locality,
      :region,
      :email,
      :contact_form_url,
      contact_numbers_attributes: %i[id label number],
    )
  end
end
