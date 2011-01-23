module DataPeriod
  DataPeriodError = Class.new(StandardError)

  class Abstract
    include CalcPeriod
    include Templates

    attr_reader :periods, :date_now, :settings, :options, :last_date, :first_date
    attr_writer :dates

    def initialize(source, source_attr, options, settings = {})
      @source = source
      @source_attr = source_attr
      @options = options
      @settings = settings
      @date_now = settings[:date_now] || Date.today
      @last_date = (settings[:last_date] || source.maximum(source_attr)).to_date
      @first_date = (settings[:first_date] || source.minimum(source_attr)).to_date
      @dates = settings[:dates] if settings[:dates]
      @period_variable_name = settings[:parameter] if settings[:parameter]
      @default_period_name = settings[:default] if settings[:default]
      @reverse = true if settings[:reverse] == true
      @periods = []
      @calc_periods = []

      configure_periods
      init_finite_periods
      init_calc_periods
      sort_periods
    end

    def inspect
      {
        :date_now => date_now,
        :last_date => last_date,
        :first_date => first_date,
        :source => @source.name,
        :source_attr => @source_attr
      }.inspect
    end

    class << self
      def use_renderer(klass)
        @renderer = klass
      end

      def renderer
        @renderer || DataPeriod::Renderer
      end
    end

    def renderer
      self.class.renderer
    end

    def configure_periods
      raise DataPeriodError
    end

    def period(name, attrs = {})
      attrs[:data_period] = self
      DataPeriod::Period.new(name, attrs).tap {|p| @periods << p } unless find_period(name)
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

    def default_period
      @default_period ||=
      begin
        p = @default_period_name ? @periods.find {|p| p.name.to_s == @default_period_name.to_s && p.checked } : nil
        p || first_period
      end
    end

    def period_variable_name
      @period_variable_name || :period
    end

    def current_period
      period_name = @options[period_variable_name]
      if period_name.present?
        period = find_period(period_name)
      end
      period || default_period
    end

    def daily_periods
      @periods.select {|p| p.day? }
    end

    def available_date_range
      unless daily_periods.empty?
        periods_range_begin = daily_periods.last.date
        periods_range_end = daily_periods.first.date

        date_range_begin = date_now - 15.days
        date_range_end = date_now + 15.days

        date_begin = [periods_range_begin, date_range_begin].min
        date_end   = [periods_range_end, date_range_end].max

        date_begin..date_end
      end
    end

    def date_range
      current_period.date || (current_period.from..current_period.to)
    end

    def dates
      @dates ||= @source.find(:all, dates_options).map {|d| d.send(@source_attr).to_date }
    end

    def sort_periods
      @periods.sort!
      @periods.reverse! if @reverse
    end

    private

    def init_finite_periods
      future_period = find_period(:future)
      future_period.date = @last_date if future_period

      past_period = find_period(:past)
      past_period.date = @first_date if past_period
    end

    def dates_options
      @dates_options ||= {
        :select => @source_attr,
        :conditions => { @source_attr => available_date_range },
        :order => @source_attr,
        :group => "DATE(#{@source_attr})"
      }
    end

  end
end