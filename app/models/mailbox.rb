class Mailbox < ActiveRecord::Base
  validates :username, presence: true, uniqueness: true, length: { minimum: 5 }
  validates :password, presence: true, length: { minimum: 5 }

  before_validation :create_password

  has_many  :forwards, primary_key: :username, foreign_key: :origin

  def new_password!
    write_attribute(:password, SecureRandom.urlsafe_base64(8))
    save
  end

  def fix_forwards!
    forwards.where(enabled: true).each do | fwd |
      fwd.update_attribute :enabled, false unless fwd.valid?
    end
  end

  def enabled?
    enabled
  end

  def disabled?
    !enabled
  end

  protected

  def create_password
    write_attribute(:password, SecureRandom.urlsafe_base64(8)) if password.blank?
  end
end
