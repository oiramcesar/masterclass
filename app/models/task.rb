class Task < ApplicationRecord
  belongs_to :user

  # validate :title, :user_id, presence: true ou
  validates_presence_of :title, :user_id

end
