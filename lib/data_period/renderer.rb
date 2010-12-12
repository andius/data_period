module DataPeriod
  class Renderer
    attr_reader :helpers
    delegate :content_tag, :link_to, :javascript_tag, :to => :helpers
    
    include ApplicationHelper::Text
    
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
      wrapper(@periods.map { |p| viewer(show_period(p), p) }.join(separator))
    end
    
    def show_period(p)
      options = p.options
      return "" if !p.checked || options[:hidden] == true
      
      output_title = options[:title].call(p.title) if options[:title].present?
      output_title ||= title_view(p.title)
      
      output_date = options[:date].call(p.date) if options[:date].present?
      output_date ||= (date_view(p.date) if p.date) || ""
      
      p.title_view = output_title
      p.date_view = output_date
      
      output_view = options[:current].call(p) if p.current_period? && options[:current].present?
      output_view ||= options[:view].call(p) if options[:view].present?
      output_view ||= view(p)
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
      p.period? || p.select? || p.today? ? p.title_view : p.date_view
    end
    
    def title_view(title)
      title
    end
    
    def date_view(date)
      date.strftime("%d.%m")
    end
    
    def global_wrapper(output)
      content_tag :ul, output, :class => "data-period" 
    end
    
    def viewer_for_select(period_output, p)
      link_to(period_output, "", :onclick => "return select(this);") +
      javascript_tag { "function select(element) { alert(element); }" }
    end
    
    def viewer_for_current(period_output, p)
      content_tag(:span, period_output, :class => "data-period-current")
    end
    
    def viewer_for_standard(period_output, p)
      link_to(period_output, url_options(p))
    end
    
    def period_wrapper(p)
      content_tag(:li, yield, :class => p.current_period? ? "data-period-current" : nil )
    end
    
    def url_options(p)
      p.first_period? ? {} : { :period => p.name }
    end
    
  end
end