class DataPeriodGenerator < Rails::Generator::Base 
  def manifest 
    record do |m|
      m.file "data_period_base.rb", "lib/data_period_base.rb"
    end
  end
end
