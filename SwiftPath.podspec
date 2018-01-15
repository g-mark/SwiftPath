Pod::Spec.new do |s|
  s.name          = "SwiftPath"
  s.version       = "0.2.0"
  s.summary       = "JSONPath for Swift"
  s.homepage      = "https://github.com/g-mark/SwiftPath"
  s.license       = "MIT"
  s.author        = { "Steven Grosmark" => "steve@g-mark.com" }
  
  s.source        = { :git => "https://github.com/g-mark/SwiftPath.git", :tag => s.version.to_s }
  
  s.source_files  = "Sources", "Sources/**/*.swift"
  s.exclude_files = "Sources/Exclude"
  
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.12"
  s.tvos.deployment_target = "10.0"
  
  s.frameworks    = "Foundation"
end
