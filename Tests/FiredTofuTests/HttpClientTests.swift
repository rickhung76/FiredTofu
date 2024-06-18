import XCTest
import Combine
@testable import FiredTofu

final class HttpClientTests: XCTestCase {
	
    func testInitWithURLSession_shouldRoutWithDefaultDecisions() throws {
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: config)
		
		let client = HttpClient(urlSession: session)
		
		XCTAssertEqual(client.router.defaultDecisions.count, 5)
    }
	
	func testInitWithInjectRouter_routerDecisionsShouldReturnAsInjectedRouter() throws {
		let router = DecisionRouter(with: [BuildRequestDecision()])
		
		let client = HttpClient(decisionRouter: router)
		
		XCTAssertEqual(client.router.defaultDecisions.count, 1)
	}
	
	func testSendWithCompletionClosure_shouldCompleteWithinClosure() throws {
		let mockDecision = MockResponseDecision()
		let router = DecisionRouter(with: [mockDecision])
		let client = HttpClient(decisionRouter: router)
		let request = MockRequest(path: "\(#function)", error: nil)
		
		let exp = XCTestExpectation(description: "\(#function)")
		
		client.send(request) { result in
			exp.fulfill()
			switch result {
			case .success(let response):
				XCTAssertEqual(response.val, "MockResponse@\(#function)")
				
			case .failure(_):
				XCTFail()
			}
		}
		
		wait(for: [exp], timeout: 3)
	}
	
	func testSendErrorWithCompletionClosure_shouldErrorWithinClosure() throws {
		let mockDecision = MockResponseDecision()
		let router = DecisionRouter(with: [mockDecision])
		let client = HttpClient(decisionRouter: router)
		let error = APIErrorCode.clientError
		let request = MockRequest(path: "\(#function)", error: error)
		
		let exp = XCTestExpectation(description: "\(#function)")
		
		client.send(request) { result in
			exp.fulfill()
			switch result {
			case .success(_):
				XCTFail()
				
			case .failure(let error):
				XCTAssertEqual(error.localizedDescription, error.localizedDescription)
			}
		}
		
		wait(for: [exp], timeout: 3)
	}
	
	func testSendWithPublisher_shouldCompleteFromPublisher() throws {
		let mockDecision = MockResponseDecision()
		let router = DecisionRouter(with: [mockDecision])
		let client = HttpClient(decisionRouter: router)
		let request = MockRequest(path: "\(#function)", error: nil)
		
		let exp = XCTestExpectation(description: "\(#function)")
		
		let _ = client.send(request).sink { completion in
			switch completion {
			case .failure(let failure):
				XCTFail()
			case .finished:
				exp.fulfill()
			}
		} receiveValue: { response in
			XCTAssertEqual(response.val, "MockResponse@\(#function)")
		}

		wait(for: [exp], timeout: 3)
	}
	
	func testSendErrorWithPublisher_shouldErrorFromPublisher() throws {
		let mockDecision = MockResponseDecision()
		let router = DecisionRouter(with: [mockDecision])
		let client = HttpClient(decisionRouter: router)
		let error = APIErrorCode.clientError
		let request = MockRequest(path: "\(#function)", error: error)
		
		let exp = XCTestExpectation(description: "\(#function)")
		
		let _ = client.send(request).sink { completion in
			switch completion {
			case .failure(let failure):
				XCTAssertEqual(failure.message, error.description)
				exp.fulfill()
			case .finished:
				XCTFail()
			}
		} receiveValue: { response in
			XCTFail()
		}

		wait(for: [exp], timeout: 3)
	}
	
	func testSendWithAsync_shouldCompleteFromAsync() throws {
		let mockDecision = MockResponseDecision()
		let router = DecisionRouter(with: [mockDecision])
		let client = HttpClient(decisionRouter: router)
		let request = MockRequest(path: "\(#function)", error: nil)
		
		let exp = XCTestExpectation(description: "\(#function)")
		
		Task {
			do {
				let response = try await client.send(request)
				XCTAssertEqual(response.val, "MockResponse@\(#function)")
				exp.fulfill()
			} catch {
				XCTFail()
			}
		}
		wait(for: [exp], timeout: 3)
	}
	
	func testSendErrorWithAsync_shouldThrowErrorFromAsync() throws {
		let mockDecision = MockResponseDecision()
		let router = DecisionRouter(with: [mockDecision])
		let client = HttpClient(decisionRouter: router)
		let errorCode = APIErrorCode.clientError
		let request = MockRequest(path: "\(#function)", error: errorCode)
		
		let exp = XCTestExpectation(description: "\(#function)")
		
		Task {
			do {
				let response = try await client.send(request)
				XCTFail()
			} catch {
				XCTAssertEqual(error.localizedDescription, errorCode.description)
				exp.fulfill()
			}
		}
		wait(for: [exp], timeout: 3)
	}
}
