class DataPeriod::Basic < DataPeriod::Base
  
  #  You can use one of these examples: 
  #
  #    period "future"
  #    period "past"
  #   
  #    period( "tomorrow",
  #            :title => "The day after today",
  #            :date  => date_now + 1.day )
  #
  #    period( "next-week",
  #            :title => "Next week",
  #            :from  => date_now.next_week,
  #            :to    => date_now.next_week.end_of_week )
  #
  #    period( "1-month-ago",
  #            :title => "Month ago",
  #            :from  => date_now - 1.month )
  #    
  #    period_after "today", :title => "After today"
  #    period_after "next-today"
  #
  #    period_before "today", :title => "Before today"
  #
  #    period "select", :title => "Set period"
  #
  #    (date_now-10.days..date_now-5.days).to_a.each_with_index do |d, i|
  #      period( d.strftime("%Y-%m-%d"),
  #              :title => "Some day in the past",
  #              :date  => d )
  #    end
  
  def init_periods

    period "future"

    period( "next-week",
            :title => "След. рабочая неделя",
            :from  => date_now.next_week,
            :to    => date_now.next_week.end_of_week)
            
    period_after "today"
    
    period( "today",
            :title => "Сегодня",
            :date  => date_now )
            
    period_before "today"
    
    period( "20-days-ago",
            :title => "20",
            :date  => date_now - 20.days)

    period( "1-week-ago",
            :title => "Неделя",
            :from  => date_now - 1.week )

    period( "1-month-ago",
            :title => "Месяц",
            :from  => date_now - 1.month )

    period( "3-months-ago",
            :title => "3 месяца",
            :from  => date_now - 3.months )

    period( "6-months-ago",
            :title => "Полгода",
            :from  => date_now - 6.months )

    period( "1-year-ago",
            :title => "Год",
            :from  => date_now - 1.year )

    period( "select",
            :title => "выбрать период" )

  end

end