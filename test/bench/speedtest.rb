#!/usr/bin/env ruby

require 'bundler/setup'

require 'grok-pure'

def main(args)

  grok = Grok.new
  grok.add_patterns_from_file("#{File.dirname(__FILE__)}/../../examples/patterns/base")
  grok.compile("%{COMBINEDAPACHELOG}")

  matches = 0
  failures = 0
  lines = File.new(args[0]).readlines
  iterations = lines.length

  #while lines.length < iterations
    #lines += lines
  #end
  #lines = lines[0 .. iterations]

  start = Time.now
  lines.each do |line|
    m = grok.match(line)
    if m
      matches += 1
      m.captures
    else
      failures += 1
    end
  end
  duration = Time.now - start

  puts "Parse rate: #{iterations / duration}"
  puts matches.inspect
  puts failures.inspect
end

if ARGV.empty?
  $stderr.puts "Usage: #{$0} access_log_path"
  exit 1
end

threads = []
1.upto(2) do |i|
  threads << Thread.new { main(ARGV) }
end
threads.each(&:join)
