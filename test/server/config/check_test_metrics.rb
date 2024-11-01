
# Uses data from two sources
# 1) The minitest stdout which is tee'd to test.log
# 2) The coverage.json file which is generated from simplecov-formatter-json.rb

require_relative 'metrics'
require 'json'

# - - - - - - - - - - - - - - - - - - - - - - -
def coverage_root_dir
  ENV['COVERAGE_ROOT']
end

# - - - - - - - - - - - - - - - - - - - - - - -
def coverage_code_tab_name
  ENV['COVERAGE_CODE_TAB_NAME']
end

# - - - - - - - - - - - - - - - - - - - - - - -
def coverage_test_tab_name
  ENV['COVERAGE_TEST_TAB_NAME']
end

# - - - - - - - - - - - - - - - - - - - - - - -
def test_log
  $test_log ||= begin
    path = "#{coverage_root_dir}/#{ARGV[0]}"
    cleaned(IO.read(path))
  end
end

# - - - - - - - - - - - - - - - - - - - - - - -
def index_html
  $index_html ||= begin
    path = "#{coverage_root_dir}/index.html"
    cleaned(IO.read(path))
  end
end

# - - - - - - - - - - - - - - - - - - - - - - -
def coverage_json
  $coverage_json ||= begin
    path = "#{coverage_root_dir}/coverage.json"
    JSON.parse(IO.read(path))
  end
end

# - - - - - - - - - - - - - - - - - - - - - - -
def fail_unless_expected_version
  unless index_html.include?("v0.21.2")
    puts("ERROR: Unknown simplecov version (look at bottom of index.html)")
    exit(42)
  end
end

# - - - - - - - - - - - - - - - - - - - - - - -
def cleaned(s)
  # guard against invalid byte sequence
  s = s.encode('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
  s = s.encode('UTF-8', 'UTF-16')
end

# - - - - - - - - - - - - - - - - - - - - - - -
def number
  '[\.|\d]+'
end

# - - - - - - - - - - - - - - - - - - - - - - -
def f2(s)
  result = ("%.2f" % s).to_s
  result += '0' if result.end_with?('.0')
  result
end

# - - - - - - - - - - - - - - - - - - - - - - -
def coloured(tf)
  red = 31
  green = 32
  colourize(tf ? green : red, tf)
end

# - - - - - - - - - - - - - - - - - - - - - - -
def colourize(code, word)
  "\e[#{code}m #{word} \e[0m"
end

# - - - - - - - - - - - - - - - - - - - - - - -
def get_index_stats(name)
  coverage_json['groups'][name]
end

# - - - - - - - - - - - - - - - - - - - - - - -
def get_test_log_stats
  stats = {}

  warning_regex = /: warning:/m
  stats[:warning_count] = test_log.scan(warning_regex).size

  finished_pattern = "Finished in (#{number})s, (#{number}) runs/s"
  m = test_log.match(Regexp.new(finished_pattern))
  stats[:time]               = f2(m[1])
  stats[:tests_per_sec]      = m[2].to_i

  summary_pattern =
    %w(runs assertions failures errors skips)
    .map{ |s| "(#{number}) #{s}" }
    .join(', ')
  m = test_log.match(Regexp.new(summary_pattern))
  stats[:test_count]      = m[1].to_i
  stats[:assertion_count] = m[2].to_i
  stats[:failure_count]   = m[3].to_i
  stats[:error_count]     = m[4].to_i
  stats[:skip_count]      = m[5].to_i

  stats
end

# - - - - - - - - - - - - - - - - - - - - - - -
def table_data
  log_stats = get_test_log_stats

  test_count    = log_stats[:test_count]
  failure_count = log_stats[:failure_count]
  error_count   = log_stats[:error_count]
  warning_count = log_stats[:warning_count]
  skip_count    = log_stats[:skip_count]
  test_duration = log_stats[:time].to_f

  test_stats = get_index_stats(coverage_test_tab_name)
  code_stats = get_index_stats(coverage_code_tab_name)

  [
    [ 'test:count',       test_count,     '>=',                 1 ],
    [ nil ],
    [ 'test:failures',    failure_count,  '<=',  MAX[:failures  ] ],
    [ 'test:errors',      error_count,    '<=',  MAX[:errors    ] ],
    [ 'test:warnings',    warning_count,  '<=',  MAX[:warnings  ] ],
    [ 'test:skips',       skip_count,     '<=',  MAX[:skips     ] ],
    [ 'test:duration(s)', test_duration,  '<=',  MAX[:duration  ] ],
    [ nil ],
    [ 'test:lines:total',     test_stats['lines'   ]['total' ], '<=', MAX[:test][:lines   ][:total  ] ],
    [ 'test:lines:missed',    test_stats['lines'   ]['missed'], '<=', MAX[:test][:lines   ][:missed ] ],
    [ 'test:branches:total',  test_stats['branches']['total' ], '<=', MAX[:test][:branches][:total  ] ],
    [ 'test:branches:missed', test_stats['branches']['missed'], '<=', MAX[:test][:branches][:missed ] ],
    [ nil ],
    [ 'app:lines:total',      code_stats['lines'   ]['total' ], '<=', MAX[:code][:lines   ][:total ] ],
    [ 'app:lines:missed',     code_stats['lines'   ]['missed'], '<=', MAX[:code][:lines   ][:missed] ],
    [ 'app:branches:total',   code_stats['branches']['total' ], '<=', MAX[:code][:branches][:total ] ],
    [ 'app:branches:missed',  code_stats['branches']['missed'], '<=', MAX[:code][:branches][:missed] ],
  ]
end

# - - - - - - - - - - - - - - - - - - - - - - -
fail_unless_expected_version
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
