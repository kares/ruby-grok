require File.expand_path('../test_helper', File.dirname(__FILE__))

class PathPatternsTest < Test::Unit::TestCase
  def setup
    @grok = Grok.new
    @grok.add_patterns_from_file(BASE_PATTERNS_PATH)
    @grok.compile("%{PATH}")
  end

  def test_unix_paths
    paths = %w{/ /usr /usr/bin /usr/bin/foo /etc/motd /home/.test
               /foo/bar//baz //testing /.test /%foo% /asdf/asdf,v}
    paths.each do |path|
      assert match = @grok.match(path)
      assert_equal(path, match.captures["PATH"][0])
    end
  end

  def test_windows_paths
    paths = %w{C:\WINDOWS \\\\Foo\bar \\\\1.2.3.4\C$ \\\\some\path\here.exe}
    paths << "C:\\Documents and Settings\\"
    paths.each do |path|
      assert match = @grok.match(path)
      assert_equal(path, match.captures["PATH"][0])
    end
  end
end
