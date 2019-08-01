class EventsController < ApplicationController
  before_action :timeselect,   only: [:new,:create,:edit,:update]
  before_action :authenticate_user!
  require 'date'
  require 'active_support/core_ext/date'
  include EventsHelper
  
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
      @link="https://enigmatic-lowlands-69028.herokuapp.com/events/#{@event.id}"
      @content="新規開催イベント：#{@event.title}"
      @user=User.all
      sendmailsys
      flash[:success]="正常に登録され、会員にメールを送りました。"
      redirect_to("/events/index")
    else
      flash[:warning]="登録に失敗しました"
      render 'new'
    end
  end

  def index
    @event=Event.where('opendate >= ?',nowday).where(held:true).order(opendate: "ASC").paginate(page: params[:page], per_page: 20)
  end
  
  def indexpast
    @event=Event.where('opendate < ?',nowday).where(held:true).order(opendate: "desc").paginate(page: params[:page], per_page: 20)
  end
  
  def indexcancel
    @event=Event.where(held:false).order(opendate: "desc").paginate(page: params[:page], per_page: 20)
  end
  def show
    if session[:geturl].present?
      @url=session[:geturl]
      session.delete(:geturl)
    else
      @url=request.referer
    end
    @event = Event.find(params[:id])
    @sankasha=Participant.all
    @sankasha=Participant.where(event_id:@event.id)
    @sanka=Participant.where(event_id:@event.id,user_id:current_user.id)
    @comment=Comment.new
    @commentcontent=Comment.where(event_id:@event.id)
  end
  
  def edit
    @event = Event.find(params[:id])
    settingvalue
  end
  
  def update
    @event = Event.find(params[:id])
    settingvalue
    session[:geturl]=session[:geturl2]
    session.delete(:geturl2)
    sendmail=event_params[:sendmailmethod]
    title= @event.title
    @link="https://young-gorge-92470.herokuapp.com/events/#{@event.id}"
    if params[:commit] == "中止"
      @content="開催イベント：#{@event.title}が中止になりました"
      @event.held=false
      @event.update(event_params)
      flash[:success]="#{title}イベントの中止登録をしました"
    elsif params[:commit] == "編集＋募集停止"
      @event.recruiting=false
      @event.update(event_params)
      #@link="https://enigmatic-lowlands-69028.herokuapp.com/events/#{@event.id}"
      @content="開催イベント：#{@event.title}が編集され募集が終了しました。"
      flash[:success]="イベントの変更処理及び募集停止しました"
    elsif params[:commit] == "編集＋募集再開"
      @event.recruiting=true
      @event.update(event_params)
      #@link="https://enigmatic-lowlands-69028.herokuapp.com/events/#{@event.id}"
      @content="開催イベント：#{@event.title}が編集され募集が再開されました"
      flash[:success]="イベントの変更処理及び募集再開しました"
    elsif params[:commit] == "編集"
      @event.update(event_params)
      #@link="https://enigmatic-lowlands-69028.herokuapp.com/events/#{@event.id}"
      @content="開催イベント：#{@event.title}が編集されました"
      flash[:success]="イベントの変更処理をしました"
    else
      flash[:warning]="編集に失敗しました"
      render 'edit'
    end
    if sendmail=="3"
      @user=User.all
      sendmailsys
      flash[:warning]="会員全員にメールを送りました。"
    elsif sendmail=="1"
      @user=Participant.joins(:user).where(event_id:@event.id)
      sendmailsys2
      flash[:warning]="参加者にメールを送りました。"
    end
    redirect_to("/events/#{@event.id}")
  end
  
  def attendance
    @event = Event.find(params[:id])
    @kubun=params[:kubun]
    url=params[:url]
    user_id=current_user.id
    possiblecount=@event.capacity-@event.participants.count
    if possiblecount==0 and @kubun=="1"
      flash[:warning]="申し訳けございません。すでに満席で参加登録できません"
    elsif @kubun=="1"
      sanka=Participant.new(user_id:user_id,event_id:@event.id)
      sanka.save
      @link="https://enigmatic-lowlands-69028.herokuapp.com/events/#{sanka.event_id}"
      @content="開催イベント：#{@event.title}に#{usernamereturn(user_id)}さんが参加登録されました"
      @user=User.where(id:@event.user_id)
      sendmailsys
      flash[:success]="正常に参加登録されました"
    elsif @kubun=="2"
      if possiblecount==0
        status="full"
      end
      sanka=@participant=Participant.find_by(event_id: @event.id.to_i, user_id: current_user.id)
      @link="https://enigmatic-lowlands-69028.herokuapp.com/events/#{sanka.event_id}"
      sanka.destroy
      @content="開催イベント：#{@event.title}に#{usernamereturn(user_id)}さんがキャンセル登録されました"
      @user=User.where(id:@event.user_id)
      sendmailsys
      flash[:success]="キャンセルされました。またのご利用をお願いします。"
      if status=="full"
        @content="開催イベント：#{@event.title}が満席でしたがキャンセルが出ました。検討中の方、参加検討下さい。"
        @user=User.all
        sendmailsys
      end
    else
      flash[:warning]="登録失敗しました"
    end
    session[:geturl]=url
    redirect_to("/events/#{@event.id}")
    #render "/events/#{event_id}"
  end
  
  def commentcreate
    session[:geturl]=session[:geturl2]
    session.delete(:geturl2)
    comment=params[:comment]
    event_id=params[:event_id]
    if comment.present?
      user_id=current_user.id
      commentn=Comment.new(content:comment,user_id:user_id,event_id:event_id)
      commentn.save
      event=Event.find(event_id)
      if current_user.id!=event.user_id
        @link="https://enigmatic-lowlands-69028.herokuapp.com/events/#{event_id}"
        @content="開催イベント：#{event.title}に投稿がありました"
        @user=User.where(id:event.user_id)
        sendmailsys
      end
      flash[:success]="コメントが投稿されました"
    else
      flash[:warning]="コメント投稿に失敗しました。メッセージが入力されていません。"
    end
    redirect_to("/events/#{event_id}")
  end
  
  private
  def event_params
     params.require(:event).permit(:title, :note,:place,:placelink,:opendate,:starttime,:finishtime,:money,:capacity,:user_id,:sendmailmethod)
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
  def nowday
    now = Time.current
    today=Date.new(now.year, now.month, now.day)
    today
  end
  def sendmailsys
    @user.each do |u|
      MailsysMailer.sendmail(@content,@link,u.email).deliver_later  #メーラに作成したメソッドを呼び出す。
    end
  end
  def sendmailsys2
    @user.each do |u|
      MailsysMailer.sendmail(@content,@link,u.user.email).deliver_later  #メーラに作成したメソッドを呼び出す。
    end
  end
end