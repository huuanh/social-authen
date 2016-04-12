class Identity < ActiveRecord::Base
  belongs_to :user

  validates :uid, uniqueness: true, presence: true
  validates :user, presence: true
end
