import Foundation

public class HttpClient {
	
	public static let `default` = HttpClient()
	
	public let urlSession: URLSession
	
	init(urlSession: URLSession = URLSession(configuration: .default)) {
		self.urlSession = urlSession
	}
		
	public lazy var router: DecisionRouter = {
		DecisionRouter(with: Decisions.defaults(urlSession: urlSession))
	}()
}
