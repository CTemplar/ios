# Uncomment the next line to define a global platform for your project
# platform :ios, '12.0'

target 'Ctemplar' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Ctemplar
  	pod 'ObjectivePGP'
	pod 'Alamofire'
    	pod 'PKHUD', '~> 5.0'
	pod 'AlertHelperKit', :git => 'https://github.com/keygx/AlertHelperKit'
	pod 'KeychainSwift'
	pod "BCryptSwift"
	pod 'SideMenu', '~> 4.0.0'
    
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.1'
            end
        end
    end
    	

end
