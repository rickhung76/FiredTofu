import Foundation

public typealias UpdatePercentClosure = ((Double) -> Void)

public class DecisionRouter {
    
    private var uploadClosureCluster: [String : UpdatePercentClosure] = [:]

    /// DecisionRouter 執行節點，以 Decision 為單位執行
    private(set) var defaultDecisions: [Decision]
    
    /// Init router with default sequence decision path.
    /// If all decisions pass successfully,
    /// the response model defined Request porotocol will be obtained;
    /// Otherwise, if either decision fails, an error with APIError object will be returned.
    ///
    /// For Example:
    /// If it fails to decode data inside ParseResultDecision,
    /// the decision will return APIError with APIErrorCode: "unableToDecode".
    ///
    /// - defultDecisions = 
    /// -   [
    /// -       BuildRequestDecision(),
    /// -       SendRequestDecision(),
    /// -       RetryDecision(retryCount: 3),
    /// -       BadResponseStatusCodeDecision(),
    /// -       ParseResultDecision()
    /// -   ]
	public init(urlSession: URLSession = URLSession(configuration: .default)) {
        self.defaultDecisions = Decisions.defaults(urlSession: urlSession)
    }
    
    
    /// Init router with custom decision path.
    ///
    /// - Parameter decisions: The order in the given array will be the excution order.
    public init(with decisions: [Decision]) {
        self.defaultDecisions = decisions
    }
    
    
    /// Router send request
    /// - Parameter request: The Struct confirms Request protocol
    /// - Parameter decisions: Decision path for the given request. It's optional.
    /// - Parameter completion: Completion handler
    public func send<T: Request>(
		_ request: T, 
		decisions: [Decision]? = nil,
		updateProgress: UpdatePercentClosure? = nil,
		completion: @escaping (Result<T.Response, APIError>) -> Void
	) {
        
        let decisions = decisions ?? defaultDecisions
		
        if let updateProgress = updateProgress,
		   let send = decisions.first(where: {$0 is ProgressUpdatable}) as? ProgressUpdatable {
            send.delegate = self
            uploadClosureCluster[request.uuid] = updateProgress
        }
        
		handleDecision(
			request: request,
			decisions: decisions,
			handler: completion
		)
    }
    
    fileprivate func handleDecision<Req: Request>(
		request: Req,
		decisions: [Decision],
		handler: @escaping (Result<Req.Response, APIError>) -> Void
	) {
        guard !decisions.isEmpty else {
            fatalError("No decision left but did not reach a stop.")
        }
        
        var decisions = decisions
        let current = decisions.removeFirst()
        
        guard current.shouldApply(request: request) else {
            handleDecision(
				request: request,
				decisions: decisions,
				handler: handler
			)
            return
        }
        
        print("Apply Decision : \(request.path) - \(current)")
        current.apply(request: request, decisions: decisions) { action in
            switch action {
            case .continueWithRequest(let request):
				self.handleDecision(
					request: request,
					decisions: decisions,
					handler: handler
				)
				
            case .restartWith(let request, let decisions):
                self.send(
					request,
					decisions: decisions,
					completion: handler
				)
				
            case .errored(let error):
                print("\n - - - - - - - Decision Handler END with failure - - - - - - - - \n")
                handler(.failure(error))
				
            case .done(let value):
                print("\n - - - - - - - Decision Handler END with success - - - - - - - - \n")
                handler(.success(value))
            }
        }
    }
}

extension DecisionRouter: SessionTaskProgressDelegate {
    func sessionTask(_ request: RequestUnique, with updateProgress: Double) {
        guard let closure = uploadClosureCluster[request.uuid] else {return}
        closure(updateProgress)
    }
}
