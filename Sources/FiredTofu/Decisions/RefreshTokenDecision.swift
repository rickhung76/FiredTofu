import Foundation

public class RefreshTokenDecision: Decision {
	
	private let session: URLSession

	public init(session: URLSession) {
		self.session = session
	}
    
	public func shouldApply<Req: Request>(request: Req) -> Bool  {
        guard let response = request.rawResponse,
            let httpUrlResponse = response.response as? HTTPURLResponse else {
            return true
        }
        
        return httpUrlResponse.statusCode == 401
    }
    
	public func apply<Req: Request>(
		request: Req,
		decisions: [Decision],
		completion: @escaping (DecisionAction<Req>) -> Void
	) {
        Decisions.normalQueue.suspend()
        
        //refresh token sucess implement
        
        refreshTokenAPICall { (result) in
            switch result {
            case .success(_):
                var newDecisions = decisions
				newDecisions.insert(SendRequestDecision(
					session: self.session,
					isPriority: true
				), at: 0)
                newDecisions.insert(BuildRequestDecision(), at: 0)
                completion(.restartWith(request, newDecisions))
            case .failure(let error):
				completion(.errored(APIError(.invalidToken, error.localizedDescription)))
            }
        }
        Decisions.normalQueue.resume()
        completion(.errored(APIError.init(.authenticationError)))
    }
	
	open func refreshTokenAPICall(
		completion: @escaping (Result<String, Error>) -> Void
	) {
		fatalError("Must be override!")
	}
}
