class Response < ActiveRecord::Base
  belongs_to :consultation, foreign_key: :edition_id

  has_many :consultation_response_attachments, dependent: :destroy
  has_many :attachments, through: :consultation_response_attachments, order: [:ordering, :id], before_add: :set_order

  accepts_nested_attributes_for :consultation_response_attachments,
                                reject_if: :no_substantive_attachment_attributes?,
                                allow_destroy: true

  validates :published_on, recent_date: true, allow_blank: true

  after_save :set_published_on

  def published?
    published_on.present?
  end

  def ready_to_be_published?
    attachments.any? || summary.present?
  end

  def set_published_on
    if ready_to_be_published?
      date = if consultation_response_attachments.any?
        consultation_response_attachments.order("created_at ASC").first.created_at.to_date
      else
        Date.today
      end
      unless published?
        update_column(:published_on, date)
      end
    end
  end

  def alternative_format_contact_email
    consultation.alternative_format_contact_email
  end

  def allows_attachment_references?
    false
  end

  def can_order_attachments?
    !allows_inline_attachments?
  end

  def allows_inline_attachments?
    false
  end

  private

  def set_order(new_attachment)
    new_attachment.ordering = next_ordering unless new_attachment.ordering.present?
  end

  def next_ordering
    max = attachments.maximum(:ordering)
    max ? max + 1 : 0
  end

  def no_substantive_attachment_attributes?(attrs)
    att_attrs = attrs.fetch(:attachment_attributes, {})
    att_attrs.except(:accessible, :attachment_data_attributes).values.all?(&:blank?) &&
      att_attrs.fetch(:attachment_data_attributes, {}).values.all?(&:blank?)
  end
end
