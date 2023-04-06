# frozen_string_literal: true

require 'pry'
require 'csv'
require 'pg'

conn = PG.connect(dbname: 'change_payers', user: 'postgres', password: 'postgres')

csv = 'change_plans.csv'
table_name = 'change_plans'
drop_table = "DROP TABLE #{table_name}"

begin
  conn.exec drop_table
rescue StandardError
  puts 'no table exists'
end

columns = nil
CSV.foreach(csv) do |row|
  columns = row
  break
end

# This is really janky
table_creation = "CREATE TABLE #{table_name} ("
columns.each do |column_name|
  table_creation += "#{column_name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .downcase}        TEXT,"
end
table_creation += 'last_column TEXT'
table_creation += ')'

conn.exec(table_creation)

insert_string = "INSERT INTO #{table_name} VALUES ("

CSV.foreach(csv) do |row|
  next if row == columns

  values = row.map do |x|
    x.nil? || x.strip.empty? || x == [] ? 'NULL' : %('#{x.gsub("'", "''").strip}')
  end.join(',') + ', NULL'
  this_insert_string = "#{insert_string}#{values})"
  conn.exec this_insert_string
end
