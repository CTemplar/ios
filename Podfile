
platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

def ctemplarPods
  
  # Pods for Ctemplar
  pod 'ObjectivePGP'
  pod 'Alamofire'
  pod 'PKHUD', '~> 5.1.0'
  pod 'AlertHelperKit', :git => 'https://github.com/keygx/AlertHelperKit'
  pod 'KeychainSwift'
  pod "BCryptSwift"
  pod 'SideMenu', '~> 4.0.0'
  pod 'MGSwipeTableCell'
  pod 'Fabric'
  pod 'Crashlytics'
  
end

target 'Ctemplar' do
  ctemplarPods
end

target 'Ctemplar.dev' do
  ctemplarPods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.1'
    end
  end
end

