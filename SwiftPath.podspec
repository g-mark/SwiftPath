Pod::Spec.new do |s|
  s.name          = "SwiftPath"
  s.version       = "0.1.1"
  s.summary       = "JSONPath for Swift"
  s.homepage      = "https://github.com/g-mark/SwiftPath"
  s.license       = "MIT"
  s.author        = { "Steven Grosmark" => "steve@g-mark.com" }
  s.source        = { :git => "https://github.com/g-mark/SwiftPath.git", :tag => s.version.to_s }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.frameworks    = "Foundation"
end
