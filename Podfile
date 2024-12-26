platform :ios, '12.0'

target 'TikTok Video Feed Swift' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TikTok Video Feed Swift
  pod "GCDWebServer", "~> 3.0"
 pod 'Cache', :git => 'https://github.com/hyperoslo/Cache.git'


end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
      File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
    end
  end
end
