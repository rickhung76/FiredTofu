# FiredTofu

[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

 `FiredTofu` is a light weight Swift framework that provides a network layer for handling RESTful API requests and responses.
 
 This framework simplifies the process of making API calls by abstracting away the low-level details of networking, such as handling HTTP requests, parsing JSON responses, and handling errors. It provides a clean and intuitive API for making GET, POST, PUT, DELETE, and other types of requests.
 
 Seems very high level? Yet, there's plenty of way to adjust/inject the details of the network layer to fit your needs. Like customizing request and response interceptors, setup with self-configured URLSeesion and more...

 Supports Combine and Swift Concurrency.

## Installation
### Swift Package Manager

_Note: Instructions below are for using **SwiftPM** without the Xcode UI. It's the easiest to go to your Project Settings -> Swift Packages and add Moya from there._

To integrate using Apple's Swift package manager, without Xcode integration, add the following as a dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/rickhung76/FiredTofu.")
```

## Usage

### Define Request and Response Structure

```
// Import the framework.
import FiredTofu

// A Response struct that conforms to Decodable.
struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}

// A Request struct that conforms to Request protocol.
class UserRequest: Request {

    // Define the Decodable Response type.
    typealias Response = [User]

    // Define the host URL.
	var baseURL: String {
		"https://api.mock.com"
	}
    
    // Define the path of the API endpoint.
    var path: String {
        return "/search/users"
    }
    
    // Define the HTTP method.
    var httpMethod: HTTPMethod {
        return .get
    }
    
    // Define the request parameters for RESTFul API body.
    var parameters: Parameters? {
        return nil
    }
    
    // Define the request parameters for URL.
    var urlParameters: Parameters? {
        return ["q": userName,
                "followers": "%3E1000",
                "page": "\(page)"]
    }
    
    // Define the request body encoding method.
    var bodyEncoding: ParameterEncoding? {
        return .urlEncoding
    }
    
    // Define the request headers.
    var headers: HTTPHeaders? {
        return ["Accept" : "application/vnd.github.v3+json"]
    }
    
    // Self-defined properties.
    let searchName: String
    
    // Self-defined initializer.
    init(searchName: String) {
        self.searchName = searchName
    }
}

```

### Make API Request

```
import FiredTofu

func makeRequest(searchName: String) {
    let request = UserRequest(searchName: searchName)

    HttpClient.default.send(request) { result in
        switch result {
        case .success(let users):
            print(users)
        case .failure(let error):
            print(error)
        }
    }
}
```

FiredTofu also supports Combine and Swift Concurrency.

### Combine

```
import FiredTofu

func makeRequest(searchName: String) {
    let request = UserRequest(searchName: searchName)

    let cancellable = HttpClient.default.send(request)
        .sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print(error)
            }
        } receiveValue: { users in
            print(users)
        }
}
```

### Swift Concurrency

```
import FiredTofu

func makeRequest(searchName: String) async {
    let request = UserRequest(searchName: searchName)

    do {
        let users = try await HttpClient.default.send(request)
        print(users)
    } catch {
        print(error)
    }
}
```

Simple as that! You can now make API requests.

## Injection of URLSession
There are times you have a self-configured URLSession and want to inject it into the HttpClient. You can do so by initializing the HttpClient with the URLSession.

```
let myConfiguration = URLSessionConfiguration.default

let myUrlSession = URLSession(configuration: configuration)

let myHttpClient = HttpClient(urlSession: urlSession)

myHttpClient.send(request) { result in
    ...
}
```

<!---
## Decisions and Router