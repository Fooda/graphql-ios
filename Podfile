platform :ios, '9.0'
use_frameworks!

def availablePods
  pod 'Alamofire', '5.2.2'
end

target 'graphql-ios' do
  availablePods
end

target 'graphql-iosTests' do
  inherit! :search_paths
  availablePods
  pod 'OHHTTPStubs/Swift'
end
