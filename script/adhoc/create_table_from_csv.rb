# frozen_string_literal: true

require 'pry'
require 'csv'
require 'pg'

class CsvToPgTable
  def initialize(conn: nil, csv: nil, table_name: nil)
    @conn = conn
    @csv = csv
    @table_name = table_name
  end

  def run
    @conn = connect_to_database if @conn.nil?
    @csv = choose_csv if @csv.nil?
    @table_name = choose_table_name if @table_name.nil?
    drop_old_table
    @columns = data_types_in_columns
    create_table
    insert_data_into_table
    final_message
  end

  def integer?(string)
    string.to_i.to_s == string
  end

  def convert_camel_case_to_snake_case(column_name)
    column_name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
               .gsub(/([a-z\d])([A-Z])/, '\1_\2')
               .downcase
  end

  def format_for_insert(value_hash)
    if value_hash.nil? || value_hash.strip.empty? || value_hash == []
      'NULL'
    else
      %('#{value_hash.gsub("'",
                           "''").strip.squeeze(' ')}')
    end
  end

  def connect_to_database
    puts 'enter database name (default: change_payers)'
    dbname = gets.chomp
    dbname = 'change_payers' if dbname.empty?
    puts 'enter user (default: postgres)'
    user = gets.chomp
    user = 'postgres' if user.empty?
    puts 'password (default: postgres)'
    password = gets.chomp
    password = 'postgres' if password.empty?

    PG.connect(dbname: dbname, user: user, password: password)
  end

  def choose_csv
    csv_in_directory = Dir["#{Dir.getwd}/*.csv"]

    puts 'Choose which csv you want to import to a table by entering the number at the beginning:'

    csv_in_directory.each_with_index do |path, index|
      path.gsub!("#{Dir.getwd}/", '')
      puts "#{index}: #{path}"
    end

    chosen_index = gets.chomp

    csv = csv_in_directory[chosen_index.to_i]

    validate_chosen_index csv, chosen_index

    csv
  end

  def validate_chosen_index(csv, chosen_index)
    if !integer?(chosen_index)
      abort 'You have entered an invalid option.'
    elsif csv.nil?
      abort 'You have entered an invalid option.'
    end
  end

  def choose_table_name
    puts 'Enter table name. (will attempt to use filename if blank). ' \
         'If the tablename is the same, the old table will be dropped.'

    table_name = gets.chomp

    table_name = @csv.gsub('.csv', '') if table_name.empty?

    table_name
  end

  def drop_old_table
    drop_table = "DROP TABLE #{@table_name}"

    begin
      @conn.exec drop_table
    rescue StandardError
      puts 'no existing table to drop'
    end
  end

  def data_types_in_columns
    columns = nil
    data_type_hash = {}
    row_iteration = 0
    CSV.foreach(@csv, converters: :all) do |row|
      if row_iteration.zero?
        columns = row
        columns.each do |header|
          data_type_hash[:"#{header}"] = nil
        end
      end
      if row_iteration.positive?
        value_iteration = 0
        columns.each do |header|
          set_postgres_datatype header, data_type_hash, row[value_iteration]
          value_iteration += 1
        end
      end
      row_iteration += 1
    end

    data_type_hash
  end

  def set_postgres_datatype(header, data_type_hash, row)
    if row.instance_of?(String)
      data_type_hash[:"#{header}"] = 'TEXT'
    elsif row.instance_of?(Float) && data_type_hash[:"#{header}"] != 'TEXT'
      data_type_hash[:"#{header}"] = 'DECIMAL'
    elsif row.instance_of?(Integer) && data_type_hash[:"#{header}"].nil?
      data_type_hash[:"#{header}"] = 'BIGINT'
    end
  end

  def create_table
    table_creation = "CREATE TABLE #{@table_name} ("
    @columns.each_with_index  do |(key, _value), index|
      table_creation += ' , ' if index.positive?
      table_creation += "#{convert_camel_case_to_snake_case(key.to_s)} #{@columns[:"#{key}"]}"
    end
    table_creation += ')'

    @conn.exec(table_creation)
  end

  def insert_data_into_table
    insert_string = "INSERT INTO #{@table_name} VALUES ("

    CSV.foreach(@csv).with_index do |row, index|
      next if index.zero?

      values = row.map do |x|
        format_for_insert x
      end.join(',')
      this_insert_string = "#{insert_string}#{values})"
      @conn.exec this_insert_string
    end
  end

  def final_message
    puts "#{@table_name} has been created using #{@csv}"
  end
end

c = PG.connect(dbname: 'change_payers', user: 'postgres', password: 'postgres')
x = CsvToPgTable.new(conn: c)
x.run
