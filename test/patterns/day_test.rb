  require File.expand_path('../test_helper', File.dirname(__FILE__))

class DayPatternsTest < Test::Unit::TestCase
  def setup
    @grok = Grok.new
    @grok.add_patterns_from_file(BASE_PATTERNS_PATH)
    @grok.compile("%{DAY}")
  end

  def test_days
    days = %w{Mon Monday Tue Tuesday Wed Wednesday Thu Thursday Fri Friday
                Sat Saturday Sun Sunday}
    days.each do |day|
      assert match = @grok.match(day)
      assert_equal(day, match.captures["DAY"][0])
    end
  end

end
