
# Uses data from two sources
# 1) The minitest test_metrics.json file which is generated from slim_json_reporter.rb
# 2) The coverage.json file which is generated from simplecov-formatter-json.rb

require_relative 'metrics'
require 'json'

def coverage_root_dir
  ENV['COVERAGE_ROOT']
end

def coloured(tf)
  red = 31
  green = 32
  colourize(tf ? green : red, tf)
end

def colourize(code, word)
  "\e[#{code}m #{word} \e[0m"
end

def table_data
  stats = JSON.parse(IO.read("#{coverage_root_dir}/test_metrics.json"))

  cov_json = JSON.parse(IO.read("#{coverage_root_dir}/coverage.json"))
  test_cov = cov_json['groups'][ENV['COVERAGE_TEST_TAB_NAME']]
  code_cov = cov_json['groups'][ENV['COVERAGE_CODE_TAB_NAME']]

  [
    [ nil ],
    [ 'test:count',       stats['test_count'],     '>=',               308 ],
    [ 'test:duration(s)', stats['total_time'],     '<=',  MAX[:duration  ] ],
    [ nil ],
    [ 'test:failures',    stats['failure_count'],  '<=',  MAX[:failures  ] ],
    [ 'test:errors',      stats['error_count'],    '<=',  MAX[:errors    ] ],
    [ 'test:skips',       stats['skip_count'],     '<=',  MAX[:skips     ] ],
    [ nil ],
    [ 'test:lines:total',     test_cov['lines'   ]['total' ], '<=', MAX[:test][:lines   ][:total  ] ],
    [ 'test:lines:missed',    test_cov['lines'   ]['missed'], '<=', MAX[:test][:lines   ][:missed ] ],
    [ 'test:branches:total',  test_cov['branches']['total' ], '<=', MAX[:test][:branches][:total  ] ],
    [ 'test:branches:missed', test_cov['branches']['missed'], '<=', MAX[:test][:branches][:missed ] ],
    [ nil ],
    [ 'app:lines:total',      code_cov['lines'   ]['total' ], '<=', MAX[:code][:lines   ][:total ] ],
    [ 'app:lines:missed',     code_cov['lines'   ]['missed'], '<=', MAX[:code][:lines   ][:missed] ],
    [ 'app:branches:total',   code_cov['branches']['total' ], '<=', MAX[:code][:branches][:total ] ],
    [ 'app:branches:missed',  code_cov['branches']['missed'], '<=', MAX[:code][:branches][:missed] ],
  ]
end

done = []
table_data.each do |name,value,op,limit|
  if name.nil?
    puts
    next
  end
  # puts "name=#{name}, value=#{value}, op=#{op}, limit=#{limit}"
  result = eval("#{value} #{op} #{limit}")
  puts "%s | %s %s %s | %s" % [
    name.rjust(25), value.to_s.rjust(5), "  #{op}", limit.to_s.rjust(5), coloured(result)
  ]
  done << result
end
puts
exit done.all?
