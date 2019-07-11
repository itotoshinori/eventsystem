class EventsController < ApplicationController
   before_action :timeselect,   only: [:new,:create]
   before_action :authenticate_user!
  require 'date'
  require 'active_support/core_ext/date'
  def new
    now = Time.current
    sdate=now.since(7.days)
    @money=0
    @starthour=13
    @startmin=00
    @finishhour=18
    @finishmin=00
    @sdate=Date.new(sdate.year, sdate.month, sdate.day)
    @capacity=10
    @event=Event.new
  end
  
  def create
    @event = Event.new(event_params)
    sdate=@event.opendate
    @starthour=@event.starttime.hour
    @startmin=@event.starttime.min
    @finishhour=@event.finishtime.hour
    @finishmin=@event.finishtime.min
    @money=@event.money
    @capacity=@event.capacity
    @sdate=Date.new(sdate.year, sdate.month, sdate.day)
    
    if @event.save
      flash[:success]="正常に登楼されました"
      redirect_to("/events/index")
    else
      flash[:warning]="登録に失敗しました"
      render 'new'
    end
  end

  def index
    @event=Event.all.order(opendate: "ASC")
    #@event=Event.all.order(opendate: "DESC")
  end
  def show
    @event = Event.find(params[:id])
  end

  def edit
  end

  private
  def event_params
     params.require(:event).permit(:title, :note,:place,:placelink,:opendate,:starttime,:finishtime,:money,:capacity,:user_id)
  end
  def timeselect
      now = Time.current
    @dates=Array.new()
    @idate=now.tomorrow
    (@idate.to_datetime..now.next_year).each do|c|
      date = Date.new(c.year, c.month, c.day)
      iw=c.strftime("%Y年%-m月%-d日 %a")
      @dates << Datecollection.new(date,iw)
    end
  end
end