module DataPeriod
  class Base
    attr_reader :periods, :date_now, :settings, :options, :last_date, :first_date
    attr_writer :dates

    def initialize(source, source_attr, options, settings = {})
      @source = source
      @source_attr = source_attr
      @options = options
      @settings = settings
      @date_now = settings[:date_now] || Time.now.to_date
      @last_date = settings[:last_date] || source.maximum(source_attr)
      @first_date = settings[:first_date] || source.minimum(source_attr)
      @dates = settings[:dates] if settings[:dates] 
      @periods = []
      @calc_periods = []
      
      init_periods
      init_finite_periods
      init_calc_periods
      sort_periods
    end
    
    def period(name, attrs = {})
      attrs[:data_period] = self
      Period.new(name, attrs).tap {|p| @periods << p } unless find_period(name)
    end
    
    def period_after(name, attrs = {})
      add_calc_period :next, name, attrs
    end
    
    def period_before(name, attrs = {})
      add_calc_period :prev, name, attrs
    end
  
    def remove_period(period)
      p = period.kind_of?(Period) ? period : find_period(period)
      @periods.delete(p)
    end
  
    def find_period(name)
      @periods.find {|p| p.name.to_s == name.to_s }
    end
    
    def find_period_by_date(date)
      @periods.find {|p| p.checked && p.day? && p.date == date } if date
    end
    
    def first_period
      @periods.find {|p| p.checked }
    end
    
    def current_period
      period_name = @options[:period]
      if period_name.present?
        period = find_period(period_name)
      end
      period || first_period
    end
    
    def daily_periods
      @periods.select {|p| p.day? }
    end
    
    def available_date_range
      unless daily_periods.empty?
        periods_range_begin = daily_periods.last.date
        periods_range_end = daily_periods.first.date
        
        date_range_begin = date_now - 10.days
        date_range_end = date_now + 10.days
        
        date_begin = [periods_range_begin, date_range_begin].min
        date_end   = [periods_range_end, date_range_end].max
        
        date_begin..date_end
      end
    end
  
    def date_range
      current_period.date || (current_period.from..current_period.to)
    end
    
    def dates
      @dates ||= @source.find(:all, dates_options).send(:map, &@source_attr)
    end
    
    def sort_periods
      @periods.sort!
    end
  
    private

    def init_finite_periods
      future_period = find_period(:future)
      future_period.date = @last_date if future_period
      
      past_period = find_period(:past)
      past_period.date = @first_date if past_period
    end
    
    def init_calc_periods
      @calc_periods.each do |calc_attrs|
        parent_period = find_period(calc_attrs[:name])
        if parent_period && parent_period.day?
          next_date = case calc_attrs[:type]
            when :next
              dates.select {|d| d > parent_period.date_from }.first
            when :prev
              dates.select {|d| d < parent_period.date_from }.last
          end
          if next_date && !find_period_by_date(next_date)
            create_calc_period(next_date, calc_attrs)
          end
        end
      end
    end
    
    def create_calc_period(calc_date, calc_attrs)
      calc_title = calc_attrs[:title]
      calc_name  = calc_attrs[:name]
      calc_type  = calc_attrs[:type]
      
      calc_new_name  = "#{calc_type}-#{calc_name}"
      calc_new_title = "#{calc_type} #{calc_name}".capitalize
      
      calc_new_attrs = {
        :title       => calc_title || calc_new_title,
        :date        => calc_date,
        :data_period => self,
        :period_type => calc_type
      }
      @periods << Period.new(calc_new_name, calc_new_attrs)
    end
    
    def add_calc_period(period_type, name, attrs)
      @calc_periods << attrs.merge({ :name => name, :type => period_type })
    end
  
    def dates_options
      @dates_options ||= {
        :select => @source_attr, 
        :conditions => { @source_attr => available_date_range }, 
        :order => @source_attr, 
        :group => @source_attr
      }
    end

  end
end