class Api::V2::TaskSerializer < ActiveModel::Serializer
  belongs_to :user
  
  attributes :id, :title, :description, :done, :deadline, :user_id, :created_at, :updated_at, :short_description, :is_late

  def short_description
    object.description[0..10] if object.description.present?
  end

  def is_late
    Time.current > object.deadline if object.deadline.present?
  end
  
  def deadline_to_br
    I18n.l(object.deadline, format: :datetime) if object.deadline.present?
  end

end
