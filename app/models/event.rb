class Event < ApplicationRecord
    validates :title, presence: true, length: { maximum: 20, message: 'タイトルが長すぎます' }
    validates :note, presence: true
    validates :place, presence: true
    validates :opendate, presence: true
    validates :money, numericality: true
end
