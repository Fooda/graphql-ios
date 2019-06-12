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
To use the client, you need to first configure it with a custom logger and provider object. These objects should be single instances
that implement `GraphQLLogging` and `GraphQLProvider`. 

```swift
class ExampleLogger: GraphQLLogging {
    func infoGraphQL(_ message: String, params: [String: Any]? = nil) { **custom implementation** }
    func errorGraphQL(_ message: String, params: [String: Any]? = nil) { **custom implementation** }
}

class ExampleGraphQLProvider: GraphQLProvider {
    let shared = ExampleGraphQLProvider() 
    private init() {  }
    
    var sessionToken: String? { **current user's session token** }
    var host: { **base URL and client token** } 
}
```

Then configure the client before it's used: 
```swift
GraphQLClient.shared.configure(logger: exampleLogger, provider: exampleProvider)
```

### Make a request 
The GraphQL client library contains `GraphQLNode` enums which are used to build the request body. Just include the properties 
that you would like to receive. 

#### Nodes
For instance, the Node structure for the mutation "createSession" looks like this:
```swift
GraphQLMutation.createSession([
            .error([
                .code,
                .message
            ]),
            .session([
                .token,
                .user([
                    .firstName,
                    .lastName,
                    .referralCode,
                    .rewardsPhoneNumber([
                        .digits
                    ])
                ])
            ])
```
and will be converted to: 
```graphql
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
```

#### Input parameters
Sometimes the call you're making requires parameters so you will need to build a `GraphQLParameters` object. 

`.base` sends the parameters directly and `.input` nests the parameters inside of an `input` structure 

```swift 
_ = GraphQLParameters.base([
  "example": ""
])
``` 
maps to 
```json 
{
  "example": ""
}
```

and 
```swift 
_ = GraphQLParameters.input([
  "example": ""
])
```
maps to 
```json
{
  "input": {
    "example": ""
  }
}
```

#### Perform operation
Call perform operation on the client 
```swift 
let operation = GraphQLMutation.createSession(...)
let parameters = GraphQLParameters.input([:])

GraphQLClient.shared.performOperation(operation,
                                      parameters: parameters,
                                      headers: nil) { (result: Result<CustomResponse, Error>) in 
  // handle the response                                       
}
```

### Handle response 
The response of `performOperation` must conform to the `GraphQLPayload` protocol 

You can create a nested object structure that decodes directly from a JSON file: 
```swift
struct CreateSessionResponse: GraphQLPayload {
    let createSession: CreateSession

    var errors: [GraphQLNamedOperationError] {
        var errors = [GraphQLNamedOperationError]()
        if let error = createSession.error {
            errors.append(GraphQLNamedOperationError(name: "createSession", error: error))
        }
        return errors
    }

    struct CreateSession: GraphQLDecodable {
        let error: GraphQLOperationError?
        let session: Session?

        struct Session: Decodable {
            let token: String
            let user: User

            struct User: Decodable {
                let firstName: String?
                let lastName: String?
                let referralCode: String?
                let rewardsPhoneNumber: RewardsPhoneNumber?

                struct RewardsPhoneNumber: Decodable {
                    let digits: String
                    let state: String
                }
            }
        }
    }
}
```

`GraphQLPayload` is the _payload_ of the response, so everything that is directly nested inside of “data”. It must conform
to `GraphQLValidating` and `Decodable`. `GraphQLDecodable` is the operation level of a response. It always includes an
`OperationError` property as well as whatever data we query for. 

The important thing to keep in mind when constructing a response object is that it must include all properties that we
requested in the service call. Take special note of the type of each property and it’s optionality. It should exactly match
the schema of the objects in the GraphiQL docs. If a property is marked with a “!” in the docs it means that the value is
not optional. An optional property in the graphQL schema should also be optional in our response.

### (Optional) validate the response

A major difference between Fooda's REST services and GraphQL services is that error codes will be nested inside
each response rather than as a status code on the call. 

It's possible to see the following errors from Snappea: 
1. Protocol error - We receive a 200, but we see a base level error saying that our request is improperly formatted,
i.e. it doesn’t conform to the GraphQL protocol. We should never see this kind of error in production, but we do
handle for it. These are handled by the client. 
2. Server / Network - It’s possible we receive a 500 level HTTP status code or no response at all from the server.
These are handled in the client.
3. Application error - These occur at the operation level. We can get multiple application errors per service call.
These are also called `OperationError`s in the schema 

You may want to handle application errors at a granular level when you build a service request. Fortunately this is easy to do.
Just implement the `validateResponse` method on your payload struct. The default implementation of `validateResponse` is to 
throw the first operation error found in the payload. There is no need to call `validateResponse` directly. This is handled by 
the client. 

```swift 
struct CustomResponse: GraphQLPayload {
  var errors: [GraphQLNamedOperationError] { ... }
  ... 
  
  func validateResponse() {
     guard let statusCode = errors.first?.error.code else { return }
     switch statusCode: {
        ... 
     }
  }
}
```

In short, to handle validation on the response, we need to 
1. Make sure `GraphQLPayload.errors` array is updated with all the operation errors in the payload 
2. (optionally) override the `validate` call on the response object for granular control 


## Authors 

Craig Olson, craig.olson@fooda.com
