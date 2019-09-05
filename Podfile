use_frameworks!

def availablePods
  pod 'Alamofire', '4.8.2'
end

def testingPods
  pod 'OHHTTPStubs/Swift'
end

target 'graphql-ios' do
  platform :ios, '9.0'
  availablePods
end

target 'graphql-iosTests' do
  platform :ios, '9.0'
  inherit! :search_paths
  availablePods
  testingPods
end

target 'graphql-macos' do
  platform :osx, '10.14'
  availablePods
end

target 'graphql-macosTests' do
  platform :osx, '10.14'
  inherit! :search_paths
  availablePods
  testingPods
end
