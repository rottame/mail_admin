class Forward < ActiveRecord::Base
  self.table_name = 'aliases'

  validates :origin, presence: true
  validates :destinations, presence: true

  validate :unique_active
  validate :origin_as_mailbox
  validate :valid_to_self
  validate :valid_destinations
  before_save :compute_to

  belongs_to :mailbox, primary_key: :username, foreign_key: :origin

  def destinations=(dests)
    dests = dests.split(/[,\ \n]/).map(&:strip).join("\n")
    write_attribute :destinations, dests
  end

  def enabled?
    enabled
  end

  def disabled?
    !enabled
  end

  protected

  def unique_active
    chain = self.class.where(origin: self.origin).where(enabled: true)
    chain = chain.where.not(id: self.id) unless new_record?
    if chain.any?
      errors.add(:origin, :only_one_active)
      errors.add(:enabled, :only_one_active)
    end
  end

  def compute_to
    dests = destinations.split(/\n/).map(&:strip)
    dests.unshift << origin if self.to_self
    write_attribute :to, dests.uniq.join(',')
  end

  def valid_to_self
    if self.to_self && mailbox.disabled? && self.enabled?
      errors.add(:to_self, :cannot_to_self) 
    end
  end

  def origin_as_mailbox
    errors.add(:origin, :not_mailbox) unless Mailbox.where(username: origin).any?
  end

  def valid_destinations
    dests = destinations.split(/\n/).map(&:strip)
    dests = dests.reject{|d| d =~ /@/ }
    errors.add(:destinations, :do_not_add_self) if dests.include?(origin)
    if dests.any?
      existing = Alias.where(origin: dests).map(&:origin)
      existing = Mailbox.where(username: dests).map(&:username)
      existing = existing.flatten.uniq
      diff = dests - existing
      errors.add(:destinations, :destination_not_found, dests: diff.join(', ')) if diff.any?
    end
  end
end
