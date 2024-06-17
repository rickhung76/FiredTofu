import Foundation

public class HttpClient {
	
	public static let `default` = HttpClient()
	
	public let router: DecisionRouter
	
	init(urlSession: URLSession = URLSession(configuration: .default)) {
		self.router = DecisionRouter(with: Decisions.defaults(urlSession: urlSession))
	}

	
	public func send<T: Request>(
		_ request: T,
		decisions: [Decision]? = nil,
		updateProgress: UpdatePercentClosure? = nil,
		completion: @escaping (Result<T.Response, APIError>) -> Void
	) {
		router.send(
			request,
			decisions: decisions,
			updateProgress: updateProgress,
			completion: completion
		)
	}
}
