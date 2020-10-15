$: << File.join(File.dirname(__FILE__), "../lib")
require "grok-pure"

patterns = {}

matches = [
  "%{FOO=\\d+}"
]

grok = Grok.new
grok.add_patterns_from_file(File.join(File.dirname(__FILE__), "patterns/base"))
matches.collect do |m|
  grok.compile(m)
end

bytes = 0
time_start = Time.now.to_f
$stdin.each do |line|
  m = grok.match(line)
  if m
    m.each_capture do |key, value|
      p key => value
    end

    #bytes += line.length
    break
  end
end

#time_end = Time.now.to_f
#puts "parse rate: #{ (bytes / 1024) / (time_end - time_start) }"
