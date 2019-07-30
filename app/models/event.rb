class Event < ApplicationRecord
    attr_accessor :sendmailmethod
    has_many :participants
    has_many :comments
    belongs_to :user
    validates :title, presence: true
    validates :note, presence: true
    validates :place, presence: true
    validates :opendate, presence: true
    validates :money, numericality: true
end
