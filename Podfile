
platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

def ctemplarPods
  
  # Pods for Ctemplar
  pod 'ObjectivePGP'
  pod 'Alamofire', '~> 5.0.0-rc.3'
  pod 'PKHUD', '~> 5.1.0'
  pod 'AlertHelperKit', :git => 'https://github.com/keygx/AlertHelperKit'
  pod 'KeychainSwift'
  pod "BCryptSwift"
  pod 'SideMenu', '~> 4.0.0'
  pod 'MGSwipeTableCell'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase/Messaging'
  pod 'RichEditorView'
  
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

