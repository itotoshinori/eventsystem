class Event < ApplicationRecord
    has_many :participants
    validates :title, presence: true
    validates :note, presence: true
    validates :place, presence: true
    validates :opendate, presence: true
    validates :money, numericality: true
end
