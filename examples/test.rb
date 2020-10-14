#!/usr/bin/env ruby
#

$: << File.join(File.dirname(__FILE__), "../lib")

require "grok-pure"
require "pp"

grok = Grok.new

# Load some default patterns that ship with grok.
grok.add_patterns_from_file(File.join(File.dirname(__FILE__), "patterns/base"))

# Using the patterns we know, try to build a grok pattern that best matches
# a string we give. Let's try Time.now.to_s, which has this format;
# => Fri Apr 16 19:15:27 -0700 2010
input = "2010-04-18T15:06:02Z"
pattern = "%{TIMESTAMP_ISO8601}"
grok.compile(pattern)
grok.compile(pattern)
puts "Input: #{input}"
puts "Pattern: #{pattern}"
puts "Full: #{grok.expanded_pattern}"

match = grok.match(input)
if match
  puts "Resulting capture:"
  pp match.captures
end
