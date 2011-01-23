module DataPeriod
  class Renderer
    attr_reader :helpers, :data_period
    delegate :content_tag, :link_to, :javascript_tag, :to => :helpers
    delegate :period_variable_name, :current_period, :to => :data_period 
    
    def initialize(helpers, data_period, defaults)
      @helpers = helpers
      @data_period = data_period
      @periods = data_period.periods
      @controller_params = data_period.options
      @defaults = defaults

      yield(self) if block_given?
    end
    
    def period(name, options = {})
      p = @data_period.find_period(name)
      p.options = options if p
    end
    
    def separator
      @defaults[:separator] || ""
    end
    
    def viewer(period_output, p)
      return nil if period_output.empty?
      @defaults[:view] ? @defaults[:view].call(period_output, p) : default_view(period_output, p)
    end
    
    def wrapper(output)
      @defaults[:wrapper] ? @defaults[:wrapper].call(output) : global_wrapper(output)
    end
    
    def to_str
      wrapper(@periods.map { |p| viewer(show_period(p), p) }.join(separator).html_safe)
    end
    
    def show_period(p)
      options = p.options
      return "" if !p.checked || options[:hidden] == true
      
      output_title = options[:title].call(p.title) if options[:title].present?
      output_title ||= title_view(p.title)
      
      if options[:date].present? && !(p.select? && !p.current_period?)
        date_args = p.date || [p.from, p.to]
        output_date = options[:date].call(*date_args)
      end
      output_date ||= date_view(p)
      
      p.title_view = output_title
      p.date_view = output_date
      
      output_view = options[:current].call(p) if p.current_period? && options[:current].present?
      output_view ||= options[:view].call(p) if options[:view].present?
      output_view ||= view(p)
      output_view.html_safe
    end
    
    def default_view(period_output, p)
      period_wrapper(p) do
        select_period_view(period_output, p)
      end
    end
    
    def select_period_view(period_output, p)
      if p.select?
        viewer_for_select(period_output, p)
      elsif p.current_period?
        viewer_for_current(period_output, p)
      else
        viewer_for_standard(period_output, p)
      end
    end

    # You can override lower standing methods in your own renderer class

    def view(p)
      p.period? || p.today? || (p.select? && !p.current_period?) ? p.title_view : p.date_view
    end
    
    def title_view(title)
      title
    end
    
    def date_view(p)
      if p.date && !p.select?
        p.date.strftime("%d.%m")
      elsif p.period? || p.select? && p.current_period?
        p.from.strftime("%d.%m") + "&ndash;" + p.to.strftime("%d.%m")
      else
        ""
      end
    end
    
    def global_wrapper(output)
      content_tag :ul, output, :class => "data-period" 
    end
    
    def viewer_for_select(period_output, p)
      link_to(period_output, "", :onclick => "selectPeriod(); return false;", :class => "data-period-select", :id => "data_period_select")
    end
    
    def viewer_for_current(period_output, p)
      content_tag(:span, period_output)
    end
    
    def viewer_for_standard(period_output, p)
      link_to(period_output, url_options(p))
    end
    
    def period_wrapper(p)
      content_tag(:li, yield, :class => p.current_period? ? "data-period-current" : nil )
    end
    
    def url_options(p)
      data_period_options = p.default_period? ? {} : { period_variable_name => p.name }
      params = @controller_params.dup
      params.reject! {|k, v| [period_variable_name, :from, :to, :page].include?(k.to_sym) }
      data_period_options.merge(params)
    end
    
  end
end