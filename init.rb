require 'data_period'
require 'data_period/period'
require 'data_period/renderer'
require 'data_period/helpers'

ActionView::Base.send(:include, DataPeriod::Helpers)