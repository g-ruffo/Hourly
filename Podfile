# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'Hourly' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Hourly
 pod 'DropDown'

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
               end
          end
   end
end

  target 'HourlyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'HourlyUITests' do
    # Pods for testing
  end

end
