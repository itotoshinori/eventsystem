class EventsController < ApplicationController
  require 'date'
  require 'active_support/core_ext/date'
  def new
    now = Time.current
    @dates=Array.new()
    #idate= now.at_beginning_of_month
    idate=now.tomorrow
    #@dates[]
    (idate.to_datetime..now.next_year).each do|c|
      iw=c.strftime("%Y年%-m月%-d日 %a")
      @dates << Datecollection.new(c,iw)
    end
      @event=Event.new
  end

  def index
  end

  def edit
  end
end
