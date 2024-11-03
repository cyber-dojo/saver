
# Uses data from two sources
# 1) The minitest test_metrics.json file which is generated from slim_json_reporter.rb
# 2) The coverage.json file which is generated from simplecov_formatter_json.rb

require 'json'

def coloured(tf)
  red = 31
  green = 32
  colourize(tf ? green : red, tf)
end

def colourize(code, word)
  "\e[#{code}m #{word} \e[0m"
end

def table_data
  cov_root = ENV['COVERAGE_ROOT']
  stats = JSON.parse(IO.read("#{cov_root}/test_metrics.json"))

  cov_json = JSON.parse(IO.read("#{cov_root}/coverage_metrics.json"))
  test_cov = cov_json['groups'][ENV['COVERAGE_TEST_TAB_NAME']]
  code_cov = cov_json['groups'][ENV['COVERAGE_CODE_TAB_NAME']]

  [
    [ nil ],
    [ 'test.count',    stats['test_count'],    '>=',  308 ],
    [ 'test.duration', stats['total_time'],    '<=',  100 ],
    [ nil ],
    [ 'test.failures', stats['failure_count'], '<=',  0 ],
    [ 'test.errors',   stats['error_count'],   '<=',  0 ],
    [ 'test.skips',    stats['skip_count'],    '<=',  0 ],
    [ nil ],
    [ 'test.lines.total',     test_cov['lines'   ]['total' ], '<=', 1773 ],
    [ 'test.lines.missed',    test_cov['lines'   ]['missed'], '<=', 0 ],
    [ 'test.branches.total',  test_cov['branches']['total' ], '<=', 12 ],
    [ 'test.branches.missed', test_cov['branches']['missed'], '<=', 0 ],
    [ nil ],
    [ 'app.lines.total',      code_cov['lines'   ]['total' ], '<=', 1249 ],
    [ 'app.lines.missed',     code_cov['lines'   ]['missed'], '<=', 10 ],
    [ 'app.branches.total',   code_cov['branches']['total' ], '<=', 141 ],
    [ 'app.branches.missed',  code_cov['branches']['missed'], '<=', 2 ],
  ]
end

results = []
table_data.each do |name, value, op, limit|
  if name.nil?
    puts
    next
  end
  # puts "name=#{name}, value=#{value}, op=#{op}, limit=#{limit}"  # debug
  result = eval("#{value} #{op} #{limit}")
  puts "%s | %s %s %s | %s" % [
    name.rjust(25), value.to_s.rjust(5), "  #{op}", limit.to_s.rjust(5), coloured(result)
  ]
  results << result
end
puts
exit results.all?
