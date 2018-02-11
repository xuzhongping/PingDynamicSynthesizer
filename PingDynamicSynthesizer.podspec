Pod::Spec.new do |s|

  s.name         = "PingDynamicSynthesizer"
  s.version      = "0.2.1"
  s.summary      = "Auto synthesize"

  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'
 
  s.description  = "Auto synthesize setter getter methods for category"

  s.homepage     = "https://github.com/JungHsu/PingDynamicSynthesizer"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author  = { "JungHsu" => "1021057927@qq.com" }

  s.source       = { :git => "https://github.com/JungHsu/PingDynamicSynthesizer.git", :tag => "#{s.version}" }
  s.source_files  = "PingDynamicSynthesizer/**/*.{h,m}"
  s.requires_arc = true

end