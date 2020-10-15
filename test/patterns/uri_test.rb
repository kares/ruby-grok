require File.expand_path('../test_helper', File.dirname(__FILE__))

class URIPatternsTest < Test::Unit::TestCase
  def setup
    @grok = Grok.new
    @grok.add_patterns_from_file(BASE_PATTERNS_PATH)
    @grok.compile("%{URI}")
  end

  def test_urls
    urls = ["http://www.google.com", "telnet://helloworld",
            "http://www.example.com/", "http://www.example.com/test.html",
            "http://www.example.com/test.html?foo=bar",
            "http://www.example.com/test.html?foo=bar&fizzle=baz",
            "http://www.example.com:80/test.html?foo=bar&fizzle=baz",
            "https://www.example.com:443/test.html?foo=bar&fizzle=baz",
            "https://user@www.example.com:443/test.html?foo=bar&fizzle=baz",
            "https://user:pass@somehost/fetch.pl",
            "puppet:///",
            "http://www.foo.com",
            "http://www.foo.com/",
            "http://www.foo.com/?testing",
            "http://www.foo.com/?one=two",
            "http://www.foo.com/?one=two&foo=bar",
            "foo://somehost.com:12345",
            "foo://user@somehost.com:12345",
            "foo://user@somehost.com:12345/",
            "foo://user@somehost.com:12345/foo.bar/baz/fizz",
            "foo://user@somehost.com:12345/foo.bar/baz/fizz?test",
            "foo://user@somehost.com:12345/foo.bar/baz/fizz?test=1&sink&foo=4",
            "http://www.google.com/search?hl=en&source=hp&q=hello+world+%5E%40%23%24&btnG=Google+Search",
            "http://www.freebsd.org/cgi/url.cgi?ports/sysutils/grok/pkg-descr",
            "http://www.google.com/search?q=CAPTCHA+ssh&start=0&ie=utf-8&oe=utf-8&client=firefox-a&rls=org.mozilla:en-US:official",
            "svn+ssh://somehost:12345/testing",
           ]

    urls.each do |url|
      assert match = @grok.match(url)
      assert_equal(url, match.captures["URI"][0])
    end
  end

end
