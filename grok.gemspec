Gem::Specification.new do |spec|
  files = Dir.glob("lib/**/*.rb") + Dir.glob("patterns/**") + Dir.glob("test/") + ["LICENSE"]
  spec.name = "jls-grok"
  spec.version = "0.11.5"

  spec.summary = "Grok for Ruby"
  spec.description = "Grok - pattern match/extraction tool"
  spec.files = files

  spec.licenses = ['Apache-2.0']

  spec.require_paths << "lib"

  spec.authors = ["Jordan Sissel", "Pete Fritchman"]
  spec.email = ["jls@semicomplete.com", "petef@databits.net"]
  spec.homepage = "https://github.com/jordansissel/ruby-grok"
end

