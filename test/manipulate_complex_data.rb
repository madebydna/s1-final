require 'yaml'
require 'date'
require File.join(File.dirname(__FILE__), '..', 'lib', 'tabular')

@complex_data = YAML::load(open("s1-exam-data.yaml"))

@table = Tabular.new(@complex_data, :headers => true)
#raise @table.column_names.inspect

@table.select_rows do |row|
  !row[0].match(/06\/\d\d\/06/).nil?
end

@table.transform_columns("AMOUNT") do |col|
  "$#{col.to_i/100}"
end

@table.transform_columns("TARGET_AMOUNT") do |col|
  "$#{col.to_i/100}"
end

@table.transform_columns("AMTPINSPAID") do |col|
  "$#{col.to_i/100}"
end

@table.delete_column("Count")

@table.transform_columns("PROCEDURE_DATE") do |col|
  day = col[/06\/(\d\d)\/06/, 1]
  "2006-06-#{day}"
end

puts @table.rows.inspect