class Meetup < ActiveRecord::Base
  has_many :users, through: :attendees

end
