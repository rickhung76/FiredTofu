import XCTest
@testable import FiredTofu

class SendRequestDecisionTests: XCTestCase {
	
	let goodResponse =
   """
   {
     "val": "aGoodResponse"
   }
   """
	
	override func setUp() {
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = nil
	}

	override func tearDown() {
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = nil
	}
	
	func testShouldApply_shouldAlwaysTrue() throws {
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = nil
		
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: config)
		let decision = SendRequestDecision(session: session)
		let request = MockRequest(path: "\(#function)", error: nil)
		
		XCTAssertTrue(decision.shouldApply(request: request))
	}

	
	func testApplyWithGoodResponse_shouldReturnGoodResponseAndData() throws {
		let data = try XCTUnwrap(goodResponse.data(using: .utf8))
		let url = try XCTUnwrap(URL(string: "https://test.com/\(#function)"))
		
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = { request in
			let response = try XCTUnwrap(HTTPURLResponse(
				url: url,
				statusCode: 200,
				httpVersion: nil,
				headerFields: ["Content-Type": "application/json"]
			))
			return (response, data)
		}
		
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: config)
		let decision = SendRequestDecision(session: session)
		let request = MockRequest(path: "\(#function)", error: nil)
		request.formatRequest = URLRequest(url: url)
		
		let exp = XCTestExpectation(description: "\(#function)")
		
		decision.apply(request: request, decisions: []) { action in
			switch action {
			case .continueWithRequest(let req):
				XCTAssertEqual(req.rawResponse?.data, data)
				XCTAssertEqual(req.rawResponse?.response?.url, url)
				XCTAssertNil(req.rawResponse?.error)
			default:
				XCTFail()
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 3)
	}
	
	func testApplyWithError_shouldReturnError() throws {
		let url = try XCTUnwrap(URL(string: "https://test.com/\(#function)"))
		let urlError = NSError(domain: "MockURLProtocol", code: 1234)
		
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = { request in
			throw urlError
		}
		
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: config)
		let decision = SendRequestDecision(session: session)
		let request = MockRequest(path: "\(#function)", error: nil)
		request.formatRequest = URLRequest(url: url)
		
		let exp = XCTestExpectation(description: "\(#function)")
		
		decision.apply(request: request, decisions: []) { action in
			switch action {
			case .continueWithRequest(let req):
				if let error = req.rawResponse?.error as? NSError {
					XCTAssertEqual(error.domain, urlError.domain)
					XCTAssertEqual(error.code, urlError.code)
				} else {
					XCTFail()
				}
				XCTAssertNil(req.rawResponse?.response)
				XCTAssertNil(req.rawResponse?.data)
			default:
				XCTFail()
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 3)
	}
	
	func testApplyWithMissingFormatRequest_shouldReturnMissingRequestError() throws {
		let apiError = APIError(.missingRequest)
		
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = nil
		
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: config)
		let decision = SendRequestDecision(session: session)
		let request = MockRequest(path: "\(#function)", error: nil)
		
		let exp = XCTestExpectation(description: "\(#function)")
		
		decision.apply(request: request, decisions: []) { action in
			switch action {
			case .errored(let error):
				XCTAssertEqual(error.statusCode, apiError.statusCode)
				XCTAssertEqual(error.message, apiError.message)
			default:
				XCTFail()
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 3)
	}
	
	func testApplyWithInvalidRequest_shouldReturnDeprecatedRequestError() throws {
		let url = try XCTUnwrap(URL(string: "https://test.com/\(#function)"))
		let apiError = APIError(.deprecatedRequest)
		
		MockURLProtocol.error = nil
		MockURLProtocol.requestHandler = nil
		
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: config)
		let decision = SendRequestDecision(session: session)
		let request = MockRequest(path: "\(#function)", error: nil)
		request.formatRequest = URLRequest(url: url)
		request.isValid = false
		
		let exp = XCTestExpectation(description: "\(#function)")
		
		decision.apply(request: request, decisions: []) { action in
			switch action {
			case .errored(let error):
				XCTAssertEqual(error.statusCode, apiError.statusCode)
				XCTAssertEqual(error.message, apiError.message)
			default:
				XCTFail()
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 3)
	}
}
