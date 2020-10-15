require File.expand_path('../test_helper', File.dirname(__FILE__))

class IPPatternsTest < Test::Unit::TestCase
  def setup
    @grok = Grok.new
    @grok.add_patterns_from_file(BASE_PATTERNS_PATH)
  end

  def test_ips
    @grok.compile("%{IP}")
    File.open("#{File.dirname(__FILE__)}/../fixtures/ip.input").each do |line|
      line.chomp!
      assert match = @grok.match(line)
      assert_equal(line, match.captures["IP"][0])
    end
  end

  def test_non_ips
    @grok.compile("%{IP}")
    nonips = %w{255.255.255.256 0.1.a.33 300.1.2.3 300 400.4.3.a 1.2.3.b
                1..3.4.5 hello world}
    nonips << "hello world"
    nonips.each do |input|
      assert_nil @grok.match(input)
    end
  end
end
