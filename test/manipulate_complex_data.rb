require 'yaml'
require 'date'
require File.join(File.dirname(__FILE__), '..', 'lib', 'tabular')

@complex_data = YAML::load(open("s1-exam-data.yaml"))

@table = Tabular.new(@complex_data, :headers => true)

@table.select_rows do |row|
  date = Date.strptime(row[0], "%m/%d/%y")
  date.year == 2006 && date.month == 6
end

@table.transform_columns("AMOUNT") do |col|
  "$#{col.to_i/100}".to_s
end

@table.transform_columns("TARGET_AMOUNT") do |col|
  "$#{col.to_i/100}".to_s
end

@table.transform_columns("AMTPINSPAID") do |col|
  "$#{col.to_i/100}".to_s
end

@table.delete_column("Count")

@table.transform_columns("PROCEDURE_DATE") do |col|
  date = Date.strptime(col, "%m/%d/%y")
  date.strftime("%Y-%m-%d")
end

File.open('s1-exam-data-transformed.yaml', 'w') do |f| 
  f.write(@table.to_table.to_yaml) 
end
