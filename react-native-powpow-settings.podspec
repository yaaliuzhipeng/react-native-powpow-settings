# react-native-powpow-settings.podspec

require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-powpow-settings"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-powpow-settings
                   DESC
  s.homepage     = "https://github.com/yaaliuzhipeng/react-native-powpow-settings"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "yaaliuzhipeng" => "yaaliuzhipeng@outlook.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/yaaliuzhipeng/react-native-powpow-settings.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,cc,cpp,m,mm,swift}"
  s.requires_arc = true

  s.dependency "React"
  # ...
  # s.dependency "..."
end

