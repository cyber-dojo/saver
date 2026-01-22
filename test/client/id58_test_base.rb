# frozen_string_literal: true
require 'English'
require 'minitest/autorun'
require 'minitest/reporters'
require_relative 'require_source'
require_relative 'slim_json_reporter'

reporters = [
  Minitest::Reporters::DefaultReporter.new,
  Minitest::Reporters::SlimJsonReporter.new,
  Minitest::Reporters::JUnitReporter.new("#{ENV.fetch('COVERAGE_ROOT')}/junit")
]
Minitest::Reporters.use!(reporters)

class Id58TestBase < Minitest::Test

  def initialize(arg)
    @id58 = nil
    @name58 = nil
    super
  end

  @@args = (ARGV.sort.uniq - ['--']) # eg 2m4
  @@seen_ids = {}
  @@timings = {}

  def self.test(id58, *lines, version, &test_block)
    source = test_block.source_location
    source_file = File.basename(source[0])
    source_line = source[1].to_s
    id58 = checked_id58(id58.to_s, lines)
    if @@args === [] || @@args.any?{ |arg| id58.include?(arg) }
      name58 = lines.join(' ').split('|').join("\n|")
      execute_around = lambda {
        ENV['ID58'] = id58
        @id58 = id58
        @name58 = name58
        @version = version
        id58_setup
        begin
          t1 = Time.now
          self.instance_exec(&test_block)
          t2 = Time.now
          stripped = trimmed(name58.split("\n").join)
          @@timings[id58+' '+source_file+':'+source_line+' '+stripped] = (t2 - t1)
        ensure
          unless $!.nil?
            puts($!.message)
          end
          id58_teardown
        end
      }
      name = "#{id58}:#{name58}"
      define_method("test_\n\n#{name}".to_sym, &execute_around)
    end
  end

  def trimmed(s)
    if s.length > 80
      s[0..80] + '...'
    else
      s
    end
  end

  Minitest.after_run do
    slow = @@timings.select{ |_name,secs| secs > 0.000 }
    sorted = slow.sort_by{ |name,secs| -secs }.to_h
    max_shown = 5
    size = sorted.size < max_shown ? sorted.size : max_shown
    puts
    if size != 0
      puts "Slowest #{size} tests are..."
    end
    sorted.each.with_index { |(name,secs),index|
      puts "%3.4f %-72s" % [secs,name]
      if index === size
        break
      end
    }
    puts
  end

  ID58_ALPHABET = %w{
    0 1 2 3 4 5 6 7 8 9
    A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
    a b c d e f g h i j k l m n o p q r s t u v w x y z
  }.join.tr('IiOo','').freeze

  def self.id58?(s)
    s.instance_of?(String) &&
      s.chars.all?{ |ch| ID58_ALPHABET.include?(ch) }
  end

  def self.checked_id58(id58, lines)
    method = "test '#{id58}',"
    pointer = ' ' * method.index("'") + '!'
    proposition = lines.join(' ').split('|').join("\n| ")
    pointee = ['', pointer,method, "'#{proposition}'", '', ''].join("\n")

    pointer.prepend("\n\n")
    raise "#{pointer}empty#{pointee}" if id58 === ''
    raise "#{pointer}not id58#{pointee}" unless id58?(id58)
    raise "#{pointer}duplicate#{pointee}" if duplicate?(id58)
    id58
  end

  def self.duplicate?(id58)
    @@seen_ids[id58] ||= 0
    @@seen_ids[id58] += 1
    @@seen_ids[id58] > 3
  end

  def id58_setup
  end

  def id58_teardown
  end

  def id58
    @id58
  end

  def name58
    @name58
  end

  def version
    @version
  end

end
