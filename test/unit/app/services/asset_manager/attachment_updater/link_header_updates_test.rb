require "test_helper"

class AssetManager::AttachmentUpdater::LinkHeaderUpdatesTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  describe AssetManager::AttachmentUpdater::LinkHeaderUpdates do
    let(:updater) { AssetManager::AttachmentUpdater }
    let(:attachment_data) { attachment.attachment_data }
    let(:edition) { FactoryBot.create(:published_edition) }
    let(:parent_document_url) { edition.public_url }
    let(:update_service) { mock("asset-manager-update-worker") }

    around do |test|
      AssetManager.stub_const(:AssetUpdater, update_service) do
        test.call
      end
    end

    context "when attachment doesn't belong to an edition" do
      let(:attachment) { FactoryBot.create(:file_attachment) }

      it "does not update status of any assets" do
        update_service.expects(:call).never

        updater.call(attachment_data, link_header: true)
      end
    end

    context "when attachment belongs to a draft edition" do
      let(:edition) { FactoryBot.create(:draft_edition) }
      let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf, attachable: edition) }
      let(:parent_document_url) { edition.public_url(draft: true) }

      it "sets parent_document_url for attachment using draft hostname" do
        update_service.expects(:call)
                      .with(nil, attachment_data, attachment.file.asset_manager_path, { "parent_document_url" => parent_document_url })

        updater.call(attachment_data, link_header: true)
      end
    end

    context "when attachment is not a PDF" do
      let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf, attachable: edition) }

      it "sets parent_document_url of corresponding asset" do
        update_service.expects(:call)
                      .with(nil, attachment_data, attachment.file.asset_manager_path, { "parent_document_url" => parent_document_url })

        updater.call(attachment_data, link_header: true)
      end
    end

    context "when attachment is a PDF" do
      let(:simple_pdf) { File.open(fixture_path.join("simple.pdf")) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf, attachable: edition) }

      it "sets parent_document_url for attachment & its thumbnail" do
        update_service.expects(:call)
                      .with(nil, attachment_data, attachment.file.asset_manager_path, { "parent_document_url" => parent_document_url })
        update_service.expects(:call)
                      .with(nil, attachment_data, attachment.file.thumbnail.asset_manager_path, { "parent_document_url" => parent_document_url })

        updater.call(attachment_data, link_header: true)
      end
    end
  end
end
