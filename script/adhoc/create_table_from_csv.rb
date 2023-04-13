# frozen_string_literal: true

require_relative 'csv_to_pg_table.rb'

c = PG.connect(dbname: 'change_payers', user: 'postgres', password: 'postgres')
x = CsvToPgTable.new(conn: c)
x.run
