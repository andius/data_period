module DataPeriod
  module Templates
    def period_future
      period "future"
    end
    
    def period_after_today
      period_after "today"
    end
    
    def period_today(title = "Today")
      period "today", :date => date_now, :title => title
    end
    
    def period_before_today
      period_before "today"
    end
    
    def period_week_before_today(title = "Week")
      period_before "today", :name => "1-week-ago", :period => 1.week, :title => title, :including => true
    end
    
    def period_previous_week(title = "Previous week")
      period "previous-week", :name => "previous-week", :title => title, :from => (date_now-1.week).beginning_of_week, :to => (date_now-1.week).end_of_week
    end
    
    def period_month_before_today(title = "Month")
      period_before "today", :name => "1-month-ago", :period => 1.month, :title => title, :including => true
    end
    
    def period_3_months_before_today(title = "3 months")
      period_before "today", :name => "3-months-ago", :period => 3.months, :title => title, :including => true
    end
    
    def period_6_months_before_today(title = "Half a year")
      period_before "today", :name => "6-months-ago", :period => 6.months, :title => title, :including => true
    end
    
    def period_year_before_today(title = "Year")
      period_before "today", :name => "1-year-ago", :period => 1.year, :title => title, :including => true
    end
    
    def period_past
      period "past"
    end
    
    def period_select(title = "Select period")
      period "select", :title => title
    end
  end
end