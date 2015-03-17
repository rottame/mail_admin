class Alias < ActiveRecord::Base
  validates :origin, presence: true
  validates :destinations, presence: true

  validate :unique_active
  before_save :compute_to

  def destinations=(dests)
    dests = dests.split(/[,\ \n]/).map(&:strip).join("\n")
    write_attribute :destinations, dests
  end

  protected

  def unique_active
    chain = self.class.where(origin: self.origin).where(enabled: self.enabled)
    chain = chain.where.not(id: self.id) unless new_record?
    if chain.any?
      errors.add(:origin, :only_one_active)
      errors.add(:enabled, :only_one_active)
    end
  end

  def compute_to
    dests = destinations.split(/\n/).map(&:strip)
    dests.unshift << origin
    write_attribute :to, dests.uniq.join(',')
  end
end
