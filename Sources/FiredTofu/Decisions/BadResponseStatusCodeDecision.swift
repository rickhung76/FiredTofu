import Foundation

public struct BadResponseStatusCodeDecision: Decision {
    
    public init() {}
    
    public func shouldApply<Req: Request>(request: Req) -> Bool {
        guard let response = request.rawResponse,
            let httpUrlResponse = response.response as? HTTPURLResponse else {
            return true
        }
        return !(200...299).contains(httpUrlResponse.statusCode)
    }
    
	public func apply<Req: Request>(
		request: Req,
		decisions: [Decision],
		completion: @escaping (DecisionAction<Req>) -> Void
	) {
        guard let response = request.rawResponse,
			  let httpUrlResponse = response.response as? HTTPURLResponse 
		else {
            let errRes = APIError(.missingResponse)
            completion(.errored(errRes))
            return
        }
        
        let errCode = handleHttpStatus(httpUrlResponse)
        let errRes = APIError(httpUrlResponse.statusCode, errCode.description)
        completion(.errored(errRes))
    }
    
    fileprivate func handleHttpStatus(_ response: HTTPURLResponse) -> APIErrorCode {
        switch response.statusCode {
        case 400...499: return APIErrorCode.clientError
        case 500...599: return APIErrorCode.serverError
        default:        return APIErrorCode.unknownError
        }
    }
}
