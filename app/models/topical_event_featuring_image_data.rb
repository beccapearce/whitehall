class TopicalEventFeaturingImageData < ApplicationRecord
  mount_uploader :file, FeaturedImageUploader, mount_on: :carrierwave_image

  validates :file, presence: true, if: :image_changed?
  validates_with ImageValidator, size: [960, 640], if: :image_changed?

private

  def image_changed?
    changes["carrierwave_image"].present?
  end
end
