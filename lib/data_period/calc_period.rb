module DataPeriod
  module CalcPeriod
    def period_after(parent_name, attrs = {})
      add_calc_period :next, parent_name, attrs
    end
    
    def period_before(parent_name, attrs = {})
      add_calc_period :prev, parent_name, attrs
    end
    
    def init_calc_periods
      @calc_periods.each do |calc_attrs|
        parent_period = find_period(calc_attrs[:parent_name])
        if parent_period && parent_period.day?
          
          has_period = calc_attrs.has_key?(:period)
          has_including = calc_attrs.has_key?(:including)
          parent_date_from = parent_period.date_from
          
          unless has_including
            next_date = case calc_attrs[:period_type]
              when :next
                dates.select {|d| d > parent_date_from }.first
              when :prev
                dates.select {|d| d < parent_date_from }.last
            end
          else
            if parent_date_from > @last_date
              next_date = @last_date
            else
              next_date = case calc_attrs[:period_type]
                when :next
                  dates.select {|d| d >= parent_date_from }.first
                when :prev
                  dates.select {|d| d <= parent_date_from }.last
              end
            end
          end
          
          if next_date && (has_period || !find_period_by_date(next_date))
            create_calc_period(next_date, calc_attrs)
          end
        end
      end
    end
    
    def add_calc_period(period_type, parent_name, attrs)
      @calc_periods << attrs.merge({ :parent_name => parent_name, :period_type => period_type })
    end
    
    def create_calc_period(calc_date, calc_attrs)
      calc_title = calc_attrs[:title]
      calc_name  = calc_attrs[:name]
      calc_type  = calc_attrs[:period_type]
      
      if calc_name
        calc_new_name = calc_name 
      else
        calc_name_prefix = calc_attrs[:prefix] || calc_type
        calc_new_name  = "#{calc_name_prefix}-#{calc_attrs[:parent_name]}"
      end
      
      calc_new_title = "#{calc_type} #{calc_name}".capitalize
      
      calc_spec_attrs = if calc_attrs.has_key?(:period)
        case calc_type
          when :next
            from_attr, to_attr = calc_date, (calc_date + calc_attrs[:period] - 1.day)
          when :prev
            from_attr, to_attr = (calc_date - calc_attrs[:period] + 1.day), calc_date
        end
        {
          :from => from_attr,
          :to => to_attr
        }
      else
        {
          :date => calc_date
        }
      end
      
      calc_period_attrs = calc_spec_attrs.merge({ :period_type => calc_type, :title => calc_title || calc_new_title })
      period(calc_new_name, calc_period_attrs)
    end
  end
end