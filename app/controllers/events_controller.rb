class EventsController < ApplicationController
  before_action :timeselect,   only: [:new,:create,:edit,:update]
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
    settingvalue
    
    if @event.save
      flash[:success]="正常に登録され、会員全員にメールを送りました。"
      content="新規イベントが登録されました。参加ご検討下さい"
      link="https://young-gorge-92470.herokuapp.com/events/#{@evevt.id}"
      MailsysMailer.sendmail(content,link).deliver_later  #メーラに作成したメソッドを呼び出す。
      redirect_to("/events/index")
    else
      flash[:warning]="登録に失敗しました"
      render 'new'
    end
  end

  def index
    now = Time.current
    @event=Event.where('opendate >= ?', now).order(opendate: "ASC")
  end
  def indexpast
    now = Time.current
    @event=Event.where('opendate < ?', now).order(opendate: "desc")
  end
  
  def show
    @event = Event.find(params[:id])
    @sankasha=Participant.all
    @sankasha=Participant.where(event_id:@event.id)
    @sanka=Participant.where(event_id:@event.id,user_id:current_user.id)
  end

  def edit
    @event = Event.find(params[:id])
    settingvalue
  end
  def update
    @event = Event.find(params[:id])
    settingvalue
    if @event.update(event_params)
      flash[:success]="正常に登録されました"
      redirect_to("/events/#{@event.id}")
    else
      flash[:warning]="登録に失敗しました"
      render 'edit'
    end
  end
  def attendance
    event_id=params[:id]
    kubun=params[:kubun]
    user_id=current_user.id
    if kubun=="1"
      sanka=Participant.new(user_id:user_id,event_id:event_id)
      sanka.save
      flash[:success]="正常に参加登録されました"
    elsif kubun=="2"
      sanka=@participant=Participant.find_by(event_id: event_id.to_i, user_id: current_user.id)
      sanka.destroy
      flash[:success]="#{sanka.event_id}に正常にキャンセルされました。またのご利用をお願いします(Test中)"
    else
        flash[:warning]="登録失敗しました"
    end
    redirect_to("/events/#{event_id}")
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
  def settingvalue
    sdate=@event.opendate
    @starthour=@event.starttime.hour
    @startmin=@event.starttime.min
    @finishhour=@event.finishtime.hour
    @finishmin=@event.finishtime.min
    @money=@event.money
    @capacity=@event.capacity
    @sdate=Date.new(sdate.year, sdate.month, sdate.day)
  end
end