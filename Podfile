source 'https://cdn.cocoapods.org/'

platform :ios, '16.0'
inhibit_all_warnings!   #忽略所有警告

target 'SwiftDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'SnapKit', '~> 4.0.0'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
