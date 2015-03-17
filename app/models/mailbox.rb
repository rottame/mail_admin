class Mailbox < ActiveRecord::Base
  validates :username, presence: true, uniqueness: true, length: { minimum: 7 }
  validates :password, presence: true, confirmation: true, length: { minimum: 7 }
  validates :password_confirmation, presence: true
end
