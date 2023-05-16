require "test_helper"

class Admin::DetailedGuidesControllerTest < ActionController::TestCase
  class LegacyNationalApplicabilityTest < ActionController::TestCase
    tests Admin::DetailedGuidesController

    setup do
      login_as create(:writer, organisation: create(:organisation))
      stub_request(
        :get,
        %r{\A#{Plek.find('publishing-api')}/v2/links},
      ).to_return(body: { links: {} }.to_json)
      stub_publishing_api_has_linkables([], document_type: "need")
    end

    include LegacyTestsForNationalApplicability

  private

    def edition_class
      DetailedGuide
    end
  end
end