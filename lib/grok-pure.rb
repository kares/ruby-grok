require "logger"

class Grok
  class PatternError < StandardError; end

  # The pattern input
  attr_reader :pattern

  # The fully-expanded pattern (in regex form)
  attr_reader :expanded_pattern

  # The dictionary of pattern names to pattern expressions
  attr_reader :patterns

  # The logger
  attr_accessor :logger

  PATTERN_RE = \
    /%\{    # match '%{' not prefixed with '\'
       (?<name>     # match the pattern name
         (?<pattern>[A-z0-9]+)
         (?::(?<subname>[@\[\]A-z0-9_:.-]+))?
       )
       (?:=(?<definition>
         (?:
           (?:[^{}\\]+|\\.+)+
           |
           (?<curly>\{(?:(?>[^{}]+|(?>\\[{}])+)|(\g<curly>))*\})+
         )+
       ))?
       [^}]*
     \}/x


  def initialize
    @patterns = {}
    @logger = NullLogger::INSTANCE
    @pattern = nil
    @expanded_pattern = nil
    # Captures Lambda which is generated at Grok compile time and called at match time
    @captures_func = nil
  end # def initialize

  def add_pattern(name, pattern)
    trace { "Adding pattern #{name} => #{pattern.inspect}" }
    @patterns[name] = pattern
    return nil
  end # def add_pattern

  def add_patterns_from_file(path)
    file = File.new(path, "r")
    file.each do |line|
      # Skip comments
      next if line =~ /^\s*#/
      # File format is: NAME ' '+ PATTERN '\n'
      name, pattern = line.gsub(/^\s*/, "").split(/\s+/, 2)
      # If the line is malformed, skip it.
      if pattern.nil?
        debug { ["Malformed (NAME PATTERN) line", {:line => line, :path => path}] }
        next
      end
      # Trim newline and add the pattern.
      add_pattern(name, pattern.chomp)
    end
    return nil
  ensure
    file && file.close
  end # def add_patterns_from_file

  def compile(pattern, named_captures_only=false)
    iterations_left = 10000
    @pattern = pattern
    @expanded_pattern = pattern.dup

    # Replace any instances of '%{FOO}' with that pattern.
    loop do
      if iterations_left == 0
        raise PatternError, "Deep recursion pattern compilation of #{pattern.inspect} - expanded: #{@expanded_pattern.inspect}"
      end
      iterations_left -= 1
      m = PATTERN_RE.match(@expanded_pattern)
      break if !m

      if m["definition"]
        add_pattern(m["pattern"], m["definition"])
      end

      if @patterns.include?(m["pattern"])
        regex = @patterns[m["pattern"]]
        name = m["name"]

        if named_captures_only && name.index(":").nil?
          # this has no semantic (pattern:foo) so we don't need to capture
          replacement_pattern = "(?:#{regex})"
        else
          replacement_pattern = "(?<#{name}>#{regex})"
        end

        # Ruby's String#sub() has a bug (or misfeature) that causes it to do bad
        # things to backslashes in string replacements, so let's work around it
        # See this gist for more details: https://gist.github.com/1491437
        # This hack should resolve LOGSTASH-226.
        @expanded_pattern.sub!(m[0]) { |s| replacement_pattern }
        trace { "replacement_pattern => #{replacement_pattern.inspect}" }
      else
        raise PatternError, "pattern #{m[0]} not defined"
      end
    end

    @regexp = Regexp.new(@expanded_pattern, Regexp::MULTILINE)
    debug { ["Grok compiled OK", {:pattern => pattern, :expanded_pattern => @expanded_pattern}] }

    @captures_func = compile_captures_func(@regexp)
  end

  private
  # compiles the captures lambda so runtime match can be optimized
  def compile_captures_func(re)
    re_match = ["lambda do |match, &block|"]
    re.named_captures.each do |name, indices|
      pattern, name, coerce = name.split(":")
      indices.each do |index|
        coerce = case coerce
                   when "int"; ".to_i"
                   when "float"; ".to_f"
                   else; ""
                 end
        name = pattern if name.nil?
        if coerce
          re_match << "  m = match[#{index}]"
          re_match << "  block.call(#{name.inspect}, (m ? m#{coerce} : m))"
        else
          re_match << "  block.call(#{name.inspect}, match[#{index}])"
        end
      end
    end
    re_match << "end"
    return eval(re_match.join("\n"))
  end # def compile_captures_func

  public
  def match(text)
    match = @regexp.match(text)
    if match
      debug { ["Regexp match object", {:names => match.names, :captures => match.captures}] }
      Grok::Match.new(self, match, text)
    end
  end # def match

  # Returns the matched regexp object directly for performance at the
  # cost of usability.
  #
  # Returns MatchData on success, nil on failure.
  #
  # Can be used with #capture
  def execute(text)
    @regexp.match(text)
  end

  # Optimized match and capture instead of calling them separately
  # This could be DRYed up by using #match and #capture directly
  # but there's a bit of a worry that that may lower perf.
  # This should be benchmarked!
  def match_and_capture(text)
    match = execute(text)
    if match
      debug { ["Regexp match object", {:names => match.names, :captures => match.captures}] }
      capture(match) { |k,v| yield k,v }
      return true
    else
      return false
    end
  end # def match_and_capture

  def capture(match, &block)
    @captures_func.call(match, &block)
  end # def capture

  class Match
    attr_reader :subject
    attr_reader :grok
    attr_reader :match

    def initialize(grok, match, subject)
      @grok = grok
      @match = match
      @subject = subject
      @captures = nil
    end

    def each_capture(&block)
      @grok.capture(@match, &block)
    end # def each_capture

    def captures
      if @captures.nil?
        captures = Hash.new { |h,k| h[k] = [] }
        each_capture do |key, val|
          captures[key] << val
        end
        @captures = captures
      end
      return @captures
    end # def captures

    def [](name)
      return captures[name]
    end # def []
  end # Grok::Match

  private

  def trace(&block)
    if @logger.respond_to?(:trace)
      return unless @logger.trace?
      @logger.trace Array(yield).join(' ')
    else
      return unless @logger.debug?
      @logger.debug Array(yield).join(' ')
    end
  end

  def debug(&block)
    return unless @logger.debug?
    @logger.debug Array(yield).join(' ')
  end

  class NullLogger < Logger

    def initialize
      super(File::NULL)
      self.level = 5 # Severity::UNKNOWN
    end

    INSTANCE = self.new

    def level=(severity)
      raise "can not change level (severity) for null-logger"
    end

  end
  private_constant :NullLogger

end # Grok
