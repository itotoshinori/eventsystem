module ApplicationHelper
  class Datecollection
  attr_accessor :id,:dateweek
    def initialize(id,dateweek)
      @id=id
      @dateweek=dateweek
    end
  end
  class Ptcollection
  attr_accessor :id,:name
    def initialize(id,name)
      @id=id
      @name=name
    end
  end
  def full_title(page_title = '')
    base_title = "イベント管理システム"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
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
