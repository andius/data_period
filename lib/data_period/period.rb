module DataPeriod
  class Period
    attr_accessor :title_view, :date_view, :options
    attr_reader :name, :title, :date, :from, :to, :data_period, :period_type
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
      attr_to = attrs[:to] || @data_period.date_now

      if @name.to_s == "select"
        @from = @data_period.options[:from].to_date rescue (@data_period.date_now - 1.month)
        @to = @data_period.options[:to].to_date rescue @data_period.date_now
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
    
    [:select, :future, :past].each do |stype|
      define_method("#{stype}?") { name == stype.to_s }
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

      case
        when day?
        then @date.between?(@first_date, @last_date) && @data_period.dates.include?(@date)
          
        when select?
        then !(@first_date.between?(date_now - 1.day, date_now + 1.day))
          
        when period?
        then @from < @last_date && @to > @first_date && !periods.any? {|p| p.period? && p.from < @first_date && p.from > @from }
          
        when future?
        then !periods.any? {|p| p.day? && p.checked && p.date >= @last_date } && @last_date > date_now
          
        when past?
        then @date < date_now && !periods.any? {|p| p.day? && p.checked && p.date == @date }
      end
    end
    
    [:current_period, :first_period, :default_period].each do |ptype|
      define_method("#{ptype}?") { self == @data_period.send(ptype) }
    end
    
    def today?
      @date == @data_period.date_now
    end
    
    def date_from
      @date || @from
    end
    
    def date_to
      @date || @to
    end
    
    def <=>(other)
      if date_from == other.date_from && (day? && other.period? && other.calculated? || period? && other.day? && calculated?)
        comparation_args = [self, other]
        comparation_args.reverse! if period?
        compare_day_with_period(*comparation_args)
      else
        select? ? 1 : other.select? ? -1 : other.date_from <=> date_from
      end
    end

    private
    
    def compare_day_with_period(p_day, p_period)
      case p_period.period_type
        when :next then 1
        when :prev then -1
      end
    end
  end
end