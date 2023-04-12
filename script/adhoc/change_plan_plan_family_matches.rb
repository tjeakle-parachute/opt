# frozen_string_literal: true

require 'csv'
require 'pry'
require 'fuzzy_match'
require 'amatch'
require 'pg'

start_time = Time.now

# we don't even iterate through
LOW_VALUE_WORDS = %w[health plan of group insurance inc new].freeze
# we don't adjust the value
MID_VALUE_WORDS = %w[care medical community healthcare life services].freeze
# we double the importance
HIGH_VALUE_WORDS = %w[medicare medicaid commerical advantage].freeze
# we call these 3
CARRIER_WORDS = %w[blue bluecross blueshield bcbs cross shield unitedhealthcare humana aetna].freeze

conn = PG.connect(dbname: 'change_payers', user: 'postgres', password: 'postgres')

# plan_families = conn.exec("SELECT * FROM plan_families WHERE id = '28'")

plan_family_sql = "SELECT *
                    FROM plan_families
                    WHERE last_column IS NOT NULL
                    AND plan_type = 'commercial'
                    ORDER BY TO_NUMBER(last_column, '99999999999') desc
                    LIMIT 5"

plan_families = conn.exec(plan_family_sql)
change_plans = conn.exec('SELECT * FROM change_plans')

CSV.open('change_plan_plan_family_matches.csv', 'w') do |csv|
  csv << %w[id total_orders name type match_score change_plan_payer_name change_payer_id change_insurance_type
            payer_id_word_score change_plan_word_score]
  plan_families.each do |pf|
    pf['matches'] = []
    pf['payer_ids'] = []
    pf['plan_names'] = []
    iteration_counter = 0
    change_plans.each do |cp|
      if (iteration_counter % 1000).zero?
        puts "processed #{iteration_counter} change plans for plan_family #{pf['name']}"
      end
      cp['words_matched'] = 0
      cp['match_score'] = 0
      plan_family_words = conn.exec("SELECT * FROM plan_family_words WHERE plan_family_id = '#{pf['id']}' ORDER BY TO_NUMBER(COALESCE(last_column, '0') , '99999999999') desc")
      pf['words'] = 0
      plan_family_words.each do |pfw|
        pf['words'] += 1
        # aetna
        change_plan_words = conn.exec("SELECT DISTINCT word, payer_name FROM change_plan_words WHERE payer_name = '#{conn.escape_string(cp['payer_name'])}'")
        change_plan_words.each do |cpw|
          # blue
          # aetna
          next unless cpw['word'] == pfw['word']

          cp['words_matched'] += 1
          cp['match_score'] += if CARRIER_WORDS.include?(cpw['word'])
                                 3
                               elsif HIGH_VALUE_WORDS.include?(cpw['word'])
                                 2
                               # elsif MID_VALUE_WORDS.include?(cpw['word'])
                               #   cp['match_score'] += 1
                               elsif LOW_VALUE_WORDS.include?(cpw['word'])
                                 0
                               else
                                 1
                               end
          # INSURANCE_TYPES = %w[MEDICARE MEDICAID HMO BLUE_CROSS TRICARE WORKERS_COMPENSATION].freeze
        end
      end
      iteration_counter += 1

      next unless (cp['words_matched']).positive?

      if %w[HMO BLUE_CROSS WORKERS_COMPENSATION
            TRICARE].include?(cp['insurance_type']) && pf['plan_type'] == 'commercial'
        cp['match_score'] += 1
      elsif cp['insurance_type'] == 'MEDICARE' && pf['plan_type'] == 'medicare'
        cp['match_score'] += 1
      elsif cp['insurance_type'] == 'MEDICAID' && pf['plan_type'] == 'medicaid'
        cp['match_score'] += 1
      end

      if pf['words'] == cp['words_matched'] && pf['words'] > 1
        cp['match_score'] += 3
      elsif cp['words_matched'] > 1
        cp['match_score'] += 2
      end

      unless cp['payer_id'].nil?
        cp['payer_id_match_score'] =
          cp['payer_id'].downcase.pair_distance_similar(pf['name'].downcase)
      end
      cp['name_change_plan_match_score'] = pf['name'].downcase.pair_distance_similar(cp['payer_name'].downcase)

      pf['payer_ids'].push cp['payer_id'] unless cp['payer_id'].nil?
      pf['plan_names'].push cp['payer_name']
      pf['matches'].push cp
      csv << [pf['id'], pf['last_column'], pf['name'], pf['plan_type'], cp['match_score'], cp['payer_name'],
              cp['payer_id'], cp['insurance_type'], cp['payer_id_match_score'], cp['name_change_plan_match_score']]

      # puts "Match found for plan_family #{pf['name']} and change payer #{cp['payer_name']} with #{cp['words_matched']} matched word."
    end
    pf['payer_ids'].uniq!
    # puts "There are #{pf['matches'].size} total matches for plan_family #{pf['name']}"
  end
end

end_time = Time.now

puts "time to run: #{end_time - start_time}"

binding.pry
