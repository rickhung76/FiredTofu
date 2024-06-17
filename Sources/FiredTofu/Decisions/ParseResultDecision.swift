import Foundation

public struct ParseResultDecision: Decision {
    
    public init() {}
    
    public func shouldApply<Req: Request>(request: Req) -> Bool {
        return true
    }

	public func apply<Req: Request>(
		request: Req,
		decisions: [Decision],
		completion: @escaping (DecisionAction<Req>) -> Void
	) {
        guard let response = request.rawResponse else {
            let errRes = APIError(.missingResponse)
            completion(.errored(errRes))
            return
        }
        
        guard let data = response.data else {
            let errRes = APIError(.missingData)
            completion(.errored(errRes))
            return
        }
        
        do {
            let value = try JSONDecoder().decodeIfPresent(
				Req.Response.self,
				from: data
			)
            completion(.done(value))
        } catch {
            let err = APIError(.unableToDecode)
            completion(.errored(err))
        }
    }
}
