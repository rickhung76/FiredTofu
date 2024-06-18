import Foundation
@testable import FiredTofu

struct MockResponseDecision: Decision {
	func shouldApply<Req: Request>(request: Req) -> Bool {
		true
	}
	
	func apply<Req: Request>(
		request: Req,
		decisions: [Decision],
		completion: @escaping (DecisionAction<Req>) -> Void
	) {
		if let mockReq = request as? MockRequest,
		   let errorCode = mockReq.error {
			completion(.errored(.init(errorCode)))
		} else if let response = MockResponse(val: "MockResponse@\(request.path)") as? Req.Response {
			completion(.done(response))
		} else {
			completion(.errored(.init(.missingResponse)))
		}
	}
}
