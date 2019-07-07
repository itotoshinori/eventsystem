module ApplicationHelper
  class Datecollection
  attr_accessor :id,:dateweek
    def initialize(id,dateweek)
      @id=id
      @dateweek=dateweek
    end
  end
end
