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
      @link=URL+"events/#{@event.id}"
      @content="■新規開催イベント：#{@event.title}が登録されました。参加のご検討を願います。"
      @user=User.all
      sendmailsys
      flash[:success]="正常に登録され、会員にメールを送りました"
      redirect_to "/events/#{@event.id}"
    else
      flash[:warning]="登録に失敗しました"
      render 'new'
    end
  end
  
  def calendar
    require 'date'
    @event=Event.all
    kubun=params[:kubun]
    if kubun=="1"
      @date=params[:lday].to_date
    elsif kubun=="2"
      @date=params[:lday].to_date
    else
      @date = Date.today
    end
  end
  
  def index
    @event=Event.where('opendate > ?',nowday).where(held:true).order(:opendate,:starttime).paginate(page: params[:page], per_page: 10)
  end
  def indexpast
    @event=Event.where('opendate <= ?',nowday).where(held:true).order(opendate: "desc").paginate(page: params[:page], per_page: 10)
  end
  
  def indexcancel
    @event=Event.where(held:false).order(opendate: "desc").paginate(page: params[:page], per_page: 10)
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
    @sankasha=Participant.where(event_id:@event.id).order(created_at: "ASC")
    @sanka=Participant.where(event_id:@event.id,user_id:current_user.id)
    @comment=Comment.new
    @commentcontent=Comment.where(event_id:@event.id)
    ptselect
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
    @link=URL+"events/#{@event.id}"
    if params[:commit] == "中止"
      @content="開催イベント：#{@event.title}が中止になりました"
      @event.held=false
      @event.update(event_params)
      flash[:success]="#{title}イベントの中止登録をしました"
    elsif params[:commit] == "編集＋募集停止"
      @event.recruiting=false
      @event.update(event_params)
      #@link=URL+"events/#{@event.id}"
      @content="開催イベント：#{@event.title}が編集され募集が終了しました"
      flash[:success]="イベントの変更処理及び募集停止しました"
    elsif params[:commit] == "編集＋募集再開"
      @event.recruiting=true
      @event.update(event_params)
      @content="開催イベント：#{@event.title}が編集され募集が再開されました"
      flash[:success]="イベントの変更処理及び募集再開しました"
    elsif params[:commit] == "編集"
      @event.update(event_params)
      
      @content="開催イベント：#{@event.title}が編集されました"
      flash[:success]="イベントの変更処理をしました"
    else
      flash[:warning]="編集に失敗しました"
      render 'edit'
    end
    if sendmail=="3"
      @user=User.all
      sendmailsys
      flash[:warning]="会員全員にメールを送りました"
    elsif sendmail=="1"
      @user=Participant.joins(:user).where(event_id:@event.id)
      sendmailsys2
      flash[:warning]="参加者にメールを送りました"
    end
    redirect_to("/events/#{@event.id}")
  end
  
  def attendance
    @event = Event.find(params[:id])
    @event_id=@event.id
    @kubun=params[:kubun]
    url=params[:url]
    @user_id=current_user.id
    possiblecount=@event.capacity-@event.participants.count
    if possiblecount==0 and @kubun=="1"
      flash[:warning]="申し訳けございません。すでに満席で参加登録できません"
    elsif @kubun=="1" and Participant.find_by(user_id:@user_id,event_id:@event.id).blank?
      sankatouroku
      @content="開催イベント：#{@event.title}に#{usernamereturn(@user_id)}さんが参加登録されました"
      @user=User.where(id:@event.user_id)
      sendmailsys
      flash[:success]="正常に参加登録され、主催者にメールにて通知されました"
    elsif @kubun=="2"
      if possiblecount==0
        status="full"
      end
      sankatorikesi
      @content="開催イベント：#{@event.title}に#{usernamereturn(@user_id)}さんがキャンセル登録されました"
      @user=User.where(id:@event.user_id)
      sendmailsys
      flash[:success]="キャンセル登録され、主催者にメールにて通知されました"
      if status=="full"
        @content="開催イベント：#{@event.title}が満席でしたがキャンセルが出ました。検討中の方、参加検討下さい。"
        @user=User.all
        sendmailsys
      end
    else
      flash[:warning]="登録に失敗しました"
    end
    session[:geturl]=url
    redirect_to("/events/#{@event.id}")
    #render "/events/#{event_id}"
  end
  
  def commentcreate
    session[:geturl]=session[:geturl2]
    session.delete(:geturl2)
    comment=params[:comment]
    @event_id=params[:event_id]
    hash=params[:sendmail]
    sendmail=hash["id"]
    @event = Event.find(@event_id)
    @event_id=@event.id
    @user=current_user
    @user_id=@user.id
    possiblecount=@event.capacity-@event.participants.count
    flashplus=""
    if comment.blank?
      flash[:warning]="登録に失敗しました。メッセージが入力されていません。"
    else
      if params[:commit] == "投稿+参加登録"
        if possiblecount==0
          flashplus="満席で参加不可です。"
        else
          sankatouroku
          flashplus="参加登録と"
        end
      end
      if params[:commit] == "投稿+参加取消"
        if possiblecount==0
          @content="開催イベント：#{@event.title}が満席でしたがキャンセルが出ました。検討中の方、参加検討下さい。"
          @user=User.all
          sendmailsys
        end
        sankatorikesi
        flashplus="参加取消と"
      end
      if comment.present?
        commentn=Comment.new(content:comment,user_id:@user_id,event_id:@event_id)
        commentn.save
        @link=URL+"events/#{@event_id}"
        @content="開催イベント：#{@event.title}に#{@user.name}さんから#{flashplus}投稿がありました"
          if sendmail=="a"
            @user=User.where(id:@event.user_id)
            sendmailsys
            flash[:success]="#{flashplus}コメントが投稿され、通知メールを主催者に送りました。"
          elsif sendmail=="c"
            @user=Participant.joins(:user).where(event_id:@event.id)
            sendmailsys2
            flash[:success]="#{flashplus}コメントが投稿され、通知メールを参加者に送りました"
          elsif sendmail!="b"
            @user=User.where(id:sendmail)
            sendmailsys
            flash[:success]="#{flashplus}コメントが投稿され、通知メールを#{usernamereturn(sendmail)}さんに送りました。"
        else
          flash[:success]="#{flashplus}コメントが投稿されました"
        end
      end
    end
    redirect_to("/events/#{@event_id}")
  end
  def moneycollection
    event_id=params[:event_id]
    url=params[:url]
    participant=Participant.find(params[:id])
    @kubun=params[:kubun]
    if @kubun=="1"
      participant.moneycollection=true
    elsif @kubun=="2"
      participant.moneycollection=false
    elsif @kubun=="3"
      participant.attendance=true
    else
      participant.attendance=false
    end
    participant.save
    session[:geturl]=url
    redirect_to("/events/#{event_id}") 
  end
  
  private
  def event_params
     params.require(:event).permit(:title, :note,:place,:placelink,:opendate,:starttime,:finishtime,:money,:capacity,:user_id,:sendmailmethod,:url,:urlname)
  end
  def timeselect
    now = Time.current
    @dates=Array.new()
    @idate=now
    (@idate.to_datetime..now.next_year).each do|c|
      date = Date.new(c.year, c.month, c.day)
      wd = ["日","月", "火", "水", "木", "金", "土"]
      iw=c.strftime("%Y/%m/%d(#{wd[c.wday]})")
      #iw=c.strftime("%Y年%-m月%-d日 %w(日 月 火 水 木 金 土)[c.wday]")
      @dates << Datecollection.new(date,iw)
    end
  end
  
  def ptselect
    @pts=Array.new
    @pts << Ptcollection.new("a","主催者に送る")
    @pts << Ptcollection.new("b","登録のみ")
    @pts << Ptcollection.new("c","参加者に送る")
    @user=Participant.joins(:user).where(event_id:@event.id).where.not(user_id: @event.user_id)
    @user.each do |f|
        @pts << Ptcollection.new(f.user_id.to_s,usernamereturn(f.user.id)+"さんに送る")
    end
    @userplus=Comment.joins(:user).where(event_id:@event.id).where.not(user_id: @event.user_id).group("user_id")
    @userplus.each do |f|
      if @user.where(user_id:f.user_id).empty?
        @pts << Ptcollection.new(f.user_id.to_s,usernamereturn(f.user.id)+"さんに送る")
        @user.new(user_id:f.user_id)
      end
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
    today=Date.new(now.year, now.month, now.day)-1
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
  def sankatouroku
      sanka=Participant.new(user_id:@user_id,event_id:@event.id)
      sanka.save
      @link=URL+"events/#{sanka.event_id}"
  end
  def sankatorikesi
      sanka=@participant=Participant.find_by(event_id: @event.id.to_i, user_id: @user_id)
      @link=URL+"events/#{sanka.event_id}"
      sanka.destroy
  end
  
  
  
  
end