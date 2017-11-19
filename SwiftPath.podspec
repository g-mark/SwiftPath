Pod::Spec.new do |s|
  s.name          = "SwiftPath"
  s.version       = "0.1.0"
  s.summary       = "JSONPath for Swift"
  s.homepage      = "https://github.com/g-mark/SwiftPath"
  s.license       = "MIT"
  s.author        = { "Steven Grosmark" => "steve@g-mark.com" }
  s.source        = { :git => "https://github.com/g-mark/SwiftPath.git", :commit => "3e2faea2160e53b720df231179929a972b8ed21e" }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
end
