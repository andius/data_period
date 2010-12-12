module DataPeriod
  module Helpers
    def data_period(period, options = {}, &block)
      renderer = options[:renderer] || Renderer
      concat(renderer.new(self, period, options, &block))
    end
  end
end
