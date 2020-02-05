# Fooda GraphQL
GraphQL client framework for Fooda iOS

## Installation 

graphql-ios is only available directly from this GitHub repository, using [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'graphql-ios', :git => 'git@github.com:Fooda/graphql-ios.git'
```

## Usage 

### Configure client 
Configure the client with a logger to collect logs from within the framework.

```swift
class ExampleLogger: GraphQLLogging {
    func infoGraphQL(_ message: String, params: [String: Any]? = nil) { **custom implementation** }
    func errorGraphQL(_ message: String, params: [String: Any]? = nil) { **custom implementation** }
}
```

```swift
GraphQLClient.shared.configure(logger: exampleLogger)
```

### Make a request 
The GraphQL client library contains `GraphQLRequest` which is used to build the request body.

Conform to `GraphQLRequest` to make an operation.  An example of "CreateSession" looks like this:
```swift
struct CreateSessionRequest: GraphQLRequest {
    let email: String
    let password: String

    let authentication: GraphQLAuthentication = .anonymous(sessionToken: nil)
    let name = "CreateSession"

    let query: String = """
mutation CreateSession($input:CreateSession!) {
    createSession(input:$input) {
        error {
            code
            message
        }
        session {
            token
            user {
                firstName
                lastName
                referralCode
                rewardsPhoneNumber {
                    digits
                }
            }
        }
    }
}
"""

    var variables: [String: Any] {
        return [
            "username": email,
            "password": password
        ]
    }
}
```

#### Perform operation
Call perform operation on the client.  `performOperation(...)` needs a response type that conforms to `Decodable`. 
```swift 
let request = CreateSessionRequest(email: "email", password: "password")

GraphQLClient.shared.performOperation(url: url,
                                      clientToken: clientToken,
                                      request: request,
                                      headers: nil) { (result: Result<CreateSessionResponse, Error>) in 
  // handle the response                                       
}
```
