require File.expand_path('../test_helper', File.dirname(__FILE__))

class NamedCapturesTest < Test::Unit::TestCase
  def setup
    @log_line = '31.184.238.164 - - [24/Jul/2014:05:35:37 +0530] "GET /logs/access.log HTTP/1.0" 200 69849 "http://8rursodiol.enjin.com" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.12785 YaBrowser/13.12.1599.12785 Safari/537.36" "www.dlwindianrailways.com"'
  end

  def test_named_captures_only_false
    #default named captures is turned off
    @grok = Grok.new
    @grok.add_patterns_from_file(BASE_PATTERNS_PATH)
    @grok.compile("%{COMBINEDAPACHELOG}")
    match = @grok.match(@log_line)
    assert_not_nil(match.captures["BASE10NUM"][0])
    assert_not_nil(match.captures["HOUR"][0])
    assert_not_nil(match.captures["clientip"][0])
    assert_equal(match.captures["response"][0], "200")
    assert_equal(match.captures["URIHOST"][0], "8rursodiol.enjin.com")
  end

  def test_named_captures_only_true
    @grok = Grok.new
    @grok.add_patterns_from_file(BASE_PATTERNS_PATH)
    @grok.compile("%{COMBINEDAPACHELOG}", true)
    match = @grok.match(@log_line)
    assert_equal(match.captures["BASE10NUM"], [])
    assert_equal(match.captures["HOUR"], [])
    assert_equal(match.captures["clientip"][0], "31.184.238.164")
    assert_equal(match.captures["response"][0], "200")
    assert_equal(match.captures["timestamp"][0], "24/Jul/2014:05:35:37 +0530")
  end

end
