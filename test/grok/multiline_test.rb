require File.expand_path('../test_helper', File.dirname(__FILE__))

class GrokMultilinePatternCapturingTests < Test::Unit::TestCase
  def setup
    @grok = Grok.new
    @grok.add_patterns_from_file(BASE_PATTERNS_PATH)
  end

  def test_multiline
    @grok.compile("hello%{GREEDYDATA}")
    match = @grok.match("hello world \nthis is fun")
    assert_equal(" world \nthis is fun", match.captures["GREEDYDATA"][0])

    match = @grok.match("hello world this is fun")
    assert_equal(" world this is fun", match.captures["GREEDYDATA"][0])
  end

end
