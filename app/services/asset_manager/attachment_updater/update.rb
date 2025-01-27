class AssetManager::AttachmentUpdater::Update
  def initialize(asset_manager_id, attachment_data, uploader_or_legacy_url_path, new_attributes)
    @asset_manager_id = asset_manager_id
    @attachment_data = attachment_data

    @legacy_url_path = if uploader_or_legacy_url_path.respond_to?(:asset_manager_path)
                         uploader_or_legacy_url_path.asset_manager_path
                       else
                         uploader_or_legacy_url_path
                       end

    @new_attributes = new_attributes
  end

  def call
    AssetManager::AssetUpdater.call(
      asset_manager_id,
      attachment_data,
      legacy_url_path,
      new_attributes.deep_stringify_keys,
    )
  end

  attr_reader :attachment_data, :legacy_url_path, :new_attributes, :asset_manager_id
end
