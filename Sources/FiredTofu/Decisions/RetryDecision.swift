import Foundation

public struct RetryDecision: Decision {
    
    let retryCount: Int
    let isPriority: Bool
    let session: URLSession

    public init(retryCount: Int, session: URLSession, isPriority: Bool = false) {
        self.session = session
        self.retryCount = retryCount
        self.isPriority = isPriority
    }
    
	public func shouldApply<Req: Request>(request: Req) -> Bool {
		guard let response = request.rawResponse,
			  response.error == nil,
			  response.data != nil,
			  let httpUrlResponse = response.response as? HTTPURLResponse
		else {
			return true
		}
		
		let isStatusCodeValid = (200...299).contains(httpUrlResponse.statusCode)
		return !isStatusCodeValid
	}
    
    public func apply<Req: Request>(
		request: Req,
		decisions: [Decision],
		completion: @escaping (DecisionAction<Req>) -> Void
	) {
        
		if let request = request as? DomainChangeable {
			request.setNextDomain()
		}
        
        let retryDecision = RetryDecision(
			retryCount: retryCount - 1,
			session: session,
			isPriority: isPriority
		)
        
        if retryCount > 0 {
            var newDecisions = decisions.inserting(retryDecision, at: 0)
            newDecisions.insert(SendRequestDecision(session: session,
                                                    isPriority: isPriority), at: 0)
            newDecisions.insert(BuildRequestDecision(), at: 0)
            completion(.restartWith(request, newDecisions))
        } else {
            var errRes: APIError!
            
            guard let response = request.rawResponse else {
                errRes = APIError(.missingResponse)
                completion(.errored(errRes))
                return
            }

            if let error = response.error {
				errRes = APIError(
					APIErrorCode.clientError.rawValue,
					error.localizedDescription
				)
                completion(.errored(errRes))
                return
            }
            
            guard let _ = response.response as? HTTPURLResponse else {
                errRes = APIError(.missingResponse)
                completion(.errored(errRes))
                return
            }
            
            guard response.data != nil else {
                errRes = APIError(.missingData)
                completion(.errored(errRes))
                return
            }
            
            completion(.continueWithRequest(request))
        }
    }
}
