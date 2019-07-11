module ApplicationHelper
  class Datecollection
  attr_accessor :id,:dateweek
    def initialize(id,dateweek)
      @id=id
      @dateweek=dateweek
    end
  end
  def niketa(d)
    if d.present?
      if d.to_i<10
        kekka="0"+d.to_s
      else
        kekka=d.to_s
      end
      kekka
    end
  end
end
