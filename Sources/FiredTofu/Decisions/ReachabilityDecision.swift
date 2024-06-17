import Foundation

public class ReachabilityDecision: Decision {
    
    init() {
        if Network.reachability == nil {
            Network.startDetection()
        }
    }
    
    public func shouldApply<Req>(request: Req) -> Bool where Req : Request {
        true
    }
    
    public func apply<Req>(request: Req, decisions: [Decision], completion: @escaping (DecisionAction<Req>) -> Void) where Req : Request {
        if let reachability = Network.reachability, reachability.isReachable {
            completion(.continueWithRequest(request))
        } else {
            let errorCode = APIErrorCode.isNotReachability
            completion(.errored(APIError(errorCode, errorCode.description)))
        }
    }
}
