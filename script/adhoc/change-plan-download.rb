# frozen_string_literal: true

require 'faraday'
require 'pry'
require 'csv'

INSURANCE_TYPES = %w[MEDICARE MEDICAID HMO BLUE_CROSS TRICARE WORKERS_COMPENSATION].freeze

responses = []

INSURANCE_TYPES.each do |insurance_type|
  h = {}
  h[:insurance_type] = insurance_type
  h[:response] =
    Faraday.get("https://connectcenter.changehealthcare.com/publicApi/payer/getPayerList?insuranceType=#{insurance_type.gsub(
      '_', '%20'
    )}")
  h[:plans] = JSON.parse(h[:response].body)['responseData']
  h[:plan_names] = h[:plans].map { |x| x['payerName'] }
  responses.push(h)
end

response = Faraday.get('https://connectcenter.changehealthcare.com/publicApi/payer/getPayerList')
all_plans = JSON.parse(response.body)['responseData']

counts = {}
INSURANCE_TYPES.each do |insurance_type|
  counts[:"#{insurance_type}"] = 0
end

all_plans.each do |plan|
  responses.each do |response|
    next unless response[:plan_names].include? plan['payerName']

    counts[:"#{response[:insurance_type]}"] += 1
    plan['insuranceType'] = response[:insurance_type]
    break
  end
end

counts.each do |key, value|
  puts "There are #{value} of insuranceType #{key}"
end

CSV.open('change_plans.csv', 'w') do |csv|
  csv << all_plans.first.keys
  all_plans.each do |plan|
    csv << plan.values
  end
end

# medicare_response = Faraday.get("https://connectcenter.changehealthcare.com/publicApi/payer/getPayerList?insuranceType=MEDICARE")
# medicaid_response = Faraday.get("https://connectcenter.changehealthcare.com/publicApi/payer/getPayerList?insuranceType=MEDICAID")
# all_response      = Faraday.get("https://connectcenter.changehealthcare.com/publicApi/payer/getPayerList")

# medicare_plans = JSON.parse(medicare_response.body)['responseData']
# medicaid_plans = JSON.parse(medicaid_response.body)['responseData']
# all_plans      = JSON.parse(all_response.body)['responseData']

# total_medicare_plans = 0
# total_medicaid_plans = 0
# total_other_plans    = 0

# all_plans.each do |plan|
# 	if medicare_plans.map.each { |medicare_plan| medicare_plan["payerName"] }.include? plan["payerName"]
# 		plan["insuranceType"] = "MEDICARE"
# 		total_medicare_plans += 1
# 	elsif medicaid_plans.map.each { |medicaid_plan| medicaid_plan["payerName"] }.include? plan["payerName"]
# 		plan["insuranceType"] = "MEDICAID"
# 		total_medicaid_plans += 1
# 	else
# 		plan["insuranceType"] = "OTHER"
# 		total_other_plans += 1
# 	end
# end

# puts "*" * 100
# puts "total_medicare_plans: #{total_medicare_plans}"
# puts "total_medicaid_plans: #{total_medicaid_plans}"
# puts "total_other_plans: #{total_other_plans}"
# puts "*" * 100

# CSV.open('change-plans.csv', 'w') do |csv|
#   csv << all_plans.first.keys
#   all_plans.each do |plan|
#     csv << plan.values
#   end
# end

# response
