require_relative 'test_base'

class FindTest < TestBase

  def self.id58_prefix
    '29E'
  end

  # - - - - - - - - - - - - - - - - -

  test '6CA', %w[ when body of find has no return, find returns nil ] do
    def my_find1()
      result = 4.times.find {}
      return result
    end
    result = my_find1()
    assert_nil result
  end

  test '6CB', %w[
  when body of find returns
  the find does NOT continue
  the return returns from the outer function
  ] do
    def my_find2(arg)
      nos = []
      4.times.find { |n| nos.append(n); return [nos, arg] }
      # assert "never-gets-here"
    end
    assert_equal [[0], nil], my_find2(nil)
    assert_equal [[0], 123], my_find2(123)
    assert_equal [[0], false], my_find2(false)
    assert_equal [[0], true], my_find2(true)
  end

  test '6CC', %w[
  when body of find ends with nil/false
  the find DOES continue
  result is nil/false
  when body of finds ends with anything other than nil/false
  the find does NOT continue
  result is zero ?!
  ] do
    def my_find3(arg)
      nos = []
      result = 4.times.find { |n| nos.append(n); arg }
      return [nos, result]
    end
    assert_equal [[0,1,2,3], nil], my_find3(nil)
    assert_equal [[0,1,2,3], nil], my_find3(false)

    assert_equal [[0], 0], my_find3(0)
    assert_equal [[0], 0], my_find3(true)
    assert_equal [[0], 0], my_find3("f")
  end

  test '6CD', %w[
  when body of find raises
  the find does NOT continue
  exception propagates out of method containing find call
  ] do
    nos = []
    my_find4 = lambda do 4.times.find {|n| nos.append(n); raise "42"} end
    assert_raises(RuntimeError, "42") do
      my_find4.call
    end
    assert_equal [0], nos
  end

end
