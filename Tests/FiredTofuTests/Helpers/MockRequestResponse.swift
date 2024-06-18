import Foundation
@testable import FiredTofu

struct MockResponse: Decodable {
	var val: String
}

class MockRequest: Request {
	typealias Response = MockResponse
	
	var baseURL: String { "https://test.com" }
	
	var path: String
	
	var httpMethod: FiredTofu.HTTPMethod { .post }
	
	var parameters: FiredTofu.Parameters? { nil }
	
	var urlParameters: FiredTofu.Parameters? { nil }
	
	var bodyEncoding: FiredTofu.ParameterEncoding? { nil }
	
	var headers: FiredTofu.HTTPHeaders? { nil }
	
	var error: APIErrorCode?
	
	init(path: String, error: APIErrorCode?) {
		self.path = path
		self.error = error
	}
}
