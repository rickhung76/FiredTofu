import Foundation

extension HttpClient {
	
	public func send<T: Request>(
		_ request: T,
		decisions: [Decision]? = nil,
		updateProgress: UpdatePercentClosure? = nil
	) async throws -> T.Response {
			
		return try await withCheckedThrowingContinuation { continuation in
			router.send(
				request,
				decisions: decisions,
				updateProgress: updateProgress
			) { result in
				switch result {
				case .success(let model):
					continuation.resume(with: .success(model))
				case .failure(let error):
					continuation.resume(throwing: error)
				}
			}
		}
	}
}
