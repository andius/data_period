module DataPeriod
  class Period
    attr_accessor :title_view, :date_view, :options
    attr_reader :name, :title, :date, :from, :to, :data_period
    attr_writer :date
    
    def initialize(name, attrs)
      @name = name
      @title = attrs[:title] || ""
      @data_period = attrs[:data_period]
      @period_type = attrs[:period_type]
      @last_date = @data_period.last_date
      @first_date = @data_period.first_date
      @options = {}
      
      attr_from = attrs[:from]
      attr_to = attrs[:to] || Date.today

      if @name.to_s == "select"
        @from = @data_period.options[:from].to_date rescue nil
        @to = @data_period.options[:to].to_date rescue nil
      elsif attr_from
        @from, @to = attr_from, attr_to
      else
        @date = attrs[:date] || @last_date
      end
    end

    def day?
      @date && !@from && !@to && !special_type?
    end

    def period?
      !day? && !special_type?
    end

    def select?
      name == "select"
    end
    
    def future?
      name == "future"
    end
    
    def past?
      name == "past"
    end
    
    def special_type?
      select? || future? || past?
    end
    
    def calculated?
      [:next, :prev].include?(@period_type)
    end
    
    def current_day?
      day? ? @date == @last_date : false
    end

    def checked
      date_now = @data_period.date_now
      periods = @data_period.periods

      if day?
        @date.between?(@first_date, @last_date) && @data_period.dates.include?(@date)
      elsif select?
        !(@first_date.between?(date_now - 1.day, date_now + 1.day))
      elsif period?
        @from < @last_date && @to > @first_date && !periods.any? {|p| p.period? && p.from < @first_date && p.from > @from }
      elsif future?
        !periods.any? {|p| p.day? && p.checked && p.date >= @last_date } && @last_date > date_now
      elsif past?
        @date < date_now && !periods.any? {|p| p.day? && p.checked && p.date == @date }
      end
    end
    
    def current_period?
      self == @data_period.current_period
    end
    
    def first_period?
      self == @data_period.first_period
    end
    
    def today?
      @date == @data_period.date_now
    end
    
    def date_from
      @date || @from
    end
    
    def <=>(other)
      select? ? 1 : other.select? ? -1 : other.date_from <=> date_from
    end

  end
end