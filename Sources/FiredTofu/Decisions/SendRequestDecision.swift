import Foundation

public class SendRequestDecision: Decision, ProgressUpdatable {
    
    weak var delegate: SessionTaskProgressDelegate?
    
    private let session: URLSession
    
    let isPriority: Bool

    init(session: URLSession, isPriority: Bool = false) {
        self.session = session
        self.isPriority = isPriority
    }
    
    /// SendRequestDecision
    /// - Parameter request: Request Protocol 的 Request
    public func shouldApply<Req: Request>(request: Req) -> Bool {
        return true
    }
    
	public func apply<Req: Request>(
		request: Req,
		decisions: [Decision],
		completion: @escaping (DecisionAction<Req>) -> Void
	) {
        
        guard let formatRequest = request.formatRequest else {
            let err = APIError(.missingRequest)
            completion(.errored(err))
            return
        }
        
        guard request.isValid else {
            let err = APIError(.unknownError)
            completion(.errored(err))
            return
        }
        
        let queue = isPriority ? Decisions.priorityQueue : Decisions.normalQueue
        queue.async {
            var observation: NSKeyValueObservation?
            
            let task = self.session.dataTask(with: formatRequest) { data, response, error in
                request.setResponse(data, response: response, error: error)
                completion(.continueWithRequest(request))
                observation?.invalidate()
            }
            
            observation = task.progress.observe(\.fractionCompleted) { [weak self] (progress: Progress, _) in
                self?.delegate?.sessionTask(request, with: progress.fractionCompleted)
            }
            
            request.task = task
            task.resume()
        }
    }
}
