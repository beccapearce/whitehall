class Edition < ActiveRecord::Base
  include ::Transitions
  include ActiveRecord::Transitions

  state_machine do
    state :draft
    state :published

    event :publish do
      transitions from: :draft, to: :published
    end
  end

  class PolicyHasNoUnpublishedEditionsValidator
    def validate(record)
      if record.policy && record.policy.editions.draft.any?
        record.errors.add(:policy, "has existing unpublished editions")
      end
    end
  end

  belongs_to :author, class_name: "User"
  belongs_to :policy

  scope :draft, where(state: "draft")
  scope :unsubmitted, where(state: "draft", submitted: false)
  scope :submitted, where(state: "draft", submitted: true)
  scope :published, where(state: "published")

  validates_presence_of :title, :body, :author, :policy
  validates_with PolicyHasNoUnpublishedEditionsValidator, on: :create

  def publish_as!(user, lock_version = self.lock_version)
    if !submitted?
      errors.add(:base, "Not ready for publication")
    elsif user == author
      errors.add(:base, "You are not the second set of eyes")
    elsif !user.departmental_editor?
      errors.add(:base, "Only departmental editors can publish policies")
    else
      self.lock_version = lock_version
      publish!
    end
    errors.empty?
  end

  def draft?
    !published?
  end

  def build_draft(user)
    draft_attributes = {state: "draft", author: user}
    self.class.new(attributes.merge(draft_attributes))
  end
end
