
platform :ios, '11.0'
workspace 'Ctemplar.xcworkspace'
use_frameworks!
inhibit_all_warnings!

def ctemplarPods
  # Pods for Ctemplar
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase/Messaging'
end

def shared_pods
  pod 'AlertHelperKit', :git => 'https://github.com/keygx/AlertHelperKit'
  pod 'MaterialComponents/ActivityIndicator'
  pod 'BCryptSwift'
  pod 'ObjectivePGP'
end

def inbox_pods
  pod "Colorful", "~> 3.0"
  pod 'MGSwipeTableCell'
end

target 'Utility' do
  project 'Modules/Utility/Utility.xcodeproj'
  shared_pods
end

target 'Inbox' do
  project 'Modules/Inbox/Inbox.xcodeproj'
  inbox_pods
end

target 'Ctemplar' do
  ctemplarPods
  shared_pods
  inbox_pods
end

target 'Ctemplar.dev' do
  ctemplarPods
  shared_pods
  inbox_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5'
    end
  end
end

