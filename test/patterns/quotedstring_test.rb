require File.expand_path('../test_helper', File.dirname(__FILE__))

class QuotedStringPatternsTest < Test::Unit::TestCase
  def setup
    @grok = Grok.new
    @grok.add_patterns_from_file(BASE_PATTERNS_PATH)
  end

  def test_quoted_string_common
    @grok.compile("%{QUOTEDSTRING}")
    inputs = ["hello", ""]
    quotes = %w{" ' `}
    inputs.each do |value|
      quotes.each do |quote|
        str = "#{quote}#{value}#{quote}"
        assert match = @grok.match(str)
        assert_equal(str, match.captures["QUOTEDSTRING"][0])
      end
    end
  end

  def test_quoted_string_inside_escape
    @grok.compile("%{QUOTEDSTRING}")
    quotes = %w{" ' `}
    quotes.each do |quote|
      str = "#{quote}hello \\#{quote}world\\#{quote}#{quote}"
      assert match = @grok.match(str)
      assert_equal(str, match.captures["QUOTEDSTRING"][0])
    end
  end

  def test_escaped_quotes_no_match_quoted_string
    @grok.compile("%{QUOTEDSTRING}")
    inputs = ["\\\"testing\\\"", "\\\'testing\\\'", "\\\`testing\\\`",]
    inputs.each do |value|
      assert_nil @grok.match(value)
    end
  end

  def test_non_quoted_strings_no_match
    @grok.compile("%{QUOTEDSTRING}")
    inputs = ["\\\"testing", "testing", "hello world ' something ` foo"]
    inputs.each do |value|
      assert_nil @grok.match(value)
    end
  end
end
