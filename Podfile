
platform :ios, '11.0'
workspace 'Ctemplar.xcworkspace'
use_frameworks!
inhibit_all_warnings!

def ctemplarPods
  # Pods for Ctemplar
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase/Messaging'
  pod 'EMAlertController'
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '7.5.2'

end

def pgp_pods
  pod 'ObjectivePGP'
end

def shared_pods
  pod 'MaterialComponents/ActivityIndicator'
end

def emptyState_pods
  pod 'EmptyStateKit'
end

target 'Utility' do
  project 'Modules/Utility/Utility.xcodeproj'
  shared_pods
  emptyState_pods
  pgp_pods
end

target 'Compose' do
  project 'Modules/Compose/Compose.xcodeproj'
  pgp_pods
end

target 'AppSettings' do
  project 'Modules/AppSettings/AppSettings.xcodeproj'
  shared_pods
  pgp_pods
end

target 'Ctemplar' do
  ctemplarPods
  shared_pods
  emptyState_pods
  pgp_pods
end

target 'Ctemplar.dev' do
  ctemplarPods
  shared_pods
  emptyState_pods
  pgp_pods
end

target "Ctemplar.devTests" do
  use_frameworks!
  pod 'iOSSnapshotTestCase'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5'
    end
  end
end

