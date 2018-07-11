# Uncomment the next line to define a global platform for your project

platform :ios, '9.0'
def project_pods
    # Pods for PriceBar
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'R.swift'
    pod 'GooglePlaces'
end

target 'PriceBar Prod' do
  project_pods
end


target 'PriceBar Dev' do
    project_pods
end



target 'PriceBarTests' do
    inherit! :search_paths
    pod 'Firebase'
end



