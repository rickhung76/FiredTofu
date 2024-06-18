import Combine

extension HttpClient {
	
	public func send<T: Request>(
		_ request: T,
		decisions: [Decision]? = nil,
		updateProgress: UpdatePercentClosure? = nil
	) -> AnyPublisher<T.Response, APIError> {
		
		let resultSubject = PassthroughSubject<T.Response, APIError>()
		
		router.send(
			request,
			decisions: decisions,
			updateProgress: updateProgress
		) { result in
			switch result {
			case .success(let model):
				resultSubject.send(model)
				resultSubject.send(completion: .finished)
			case .failure(let error):
				resultSubject.send(completion: .failure(error))
			}
		}
		
		return resultSubject.eraseToAnyPublisher()
	}
}
