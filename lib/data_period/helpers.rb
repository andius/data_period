module DataPeriod
  module Helpers
    def data_period(period, options = {}, &block) 
      renderer = options[:renderer] || period.renderer
      concat(renderer.new(self, period, options, &block).to_str)
    end
  end
end
