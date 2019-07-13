module EventsHelper
    require "date"
    def dateweekday(d)
        if d.present?
            nen=d.year.to_s
            if d.month<10
                mon="0"+d.month.to_s
            else
                mon="0"+d.month.to_s
            end
            if d.day<10
                date="0"+d.day.to_s
            else
                date=d.day.to_s
            end
            kekka=nen[2,2]+"年"+mon+"月"+date+"日"
        end
        kekka
    end
    
    def weekdate(d)
        if d.present?
            youbi = %w[日 月 火 水 木 金 土]
            youbi[d.wday]
        end
    end
    def timehyouji(d)
        if d.present?
            kekka=niketa(d.hour.to_s)+":"+niketa(d.min.to_s)        
        end
        kekka
    end
    def usernamereturn(i)
        if i.present?
            user=User.find(i)
            user.name
        end
    end
    def mojiseigen(moji,jisuu)
        kekka=moji
        if moji.length>jisuu.to_i
            kekka=moji[0,9]+".."
        end
        kekka
    end    
end
