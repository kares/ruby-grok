require File.expand_path('../test_helper', File.dirname(__FILE__))

class ProgPatternsTest < Test::Unit::TestCase
  def setup
    @grok = Grok.new
    @grok.add_patterns_from_file(BASE_PATTERNS_PATH)
    @grok.compile("^%{PROG}$")
  end

  def test_progs
    progs = %w{kernel foo-bar foo_bar foo/bar/baz}
    progs.each do |prog|
      match = @grok.match(prog)
      assert_not_equal(false, prog, "Expected #{prog} to match.")
      assert_equal(prog, match.captures["PROG"][0], "Expected #{prog} to match capture.")
    end
  end

end
