class DataPeriodGenerator < Rails::Generator::Base 
  def manifest 
    record do |m|
      m.file "data_period_basic.rb", "lib/data_period_basic.rb"
    end
  end
end
