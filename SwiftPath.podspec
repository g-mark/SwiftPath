Pod::Spec.new do |s|
  s.name            = "SwiftPath"
  s.version         = "0.4.0"
  s.summary         = "JSONPath for Swift"
  s.homepage        = "https://github.com/g-mark/SwiftPath"
  s.license         = "MIT"
  s.author          = { "Steven Grosmark" => "steve@g-mark.com" }
  
  s.source          = { :git => "https://github.com/g-mark/SwiftPath.git", :tag => s.version.to_s }
  
  s.swift_versions  = '4.2', '5', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7'

  s.source_files    = "Sources", "Sources/**/*.swift"
  s.exclude_files   = "Sources/Exclude"
  
  s.frameworks      = "Foundation"
  
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.12"
  s.tvos.deployment_target = "10.0"
end
