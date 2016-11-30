Pod::Spec.new do |s|
  s.name         = "DIYRefresh"
  s.version      = "1.0.0"
  s.summary      = "pull to refresh."
  s.homepage     = "https://github.com/huangjinlei/DIYRefresh"
  s.license      = "MIT"
  s.author             = { "huangjinlei" => "544705740@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/huangjinlei/DIYRefresh.git", :tag => "#{s.version}" }
  s.source_files  = "DIYRefresh/*.{swift,plist}"
end
