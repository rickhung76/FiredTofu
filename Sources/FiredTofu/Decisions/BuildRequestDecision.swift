import Foundation

public struct BuildRequestDecision: Decision {
	
	public var timeoutInterval = 10.0
	
	public init() {}
	
	public func shouldApply<Req: Request>(request: Req) -> Bool {
		return true
	}
	
	public func apply<Req: Request>(
		request: Req,
		decisions: [Decision],
		completion: @escaping (DecisionAction<Req>) -> Void
	) {
		
		do {
			let formatRequest = try buildRequest(from: request)
			request.setFormatRequest(formatRequest)
			APILogger.log(request: formatRequest)
			completion(.continueWithRequest(request))
		} catch {
			let err = APIError(.encodingFailed, error.localizedDescription)
			completion(.errored(err))
		}
	}
	
	fileprivate func buildRequest<Req: Request>(
		from request: Req
	) throws -> URLRequest {
		
		guard let url = URL(string: request.baseURL + request.path) else {
			throw APIError(.missingURL)
		}
		
		var urlRequest = URLRequest(
			url: url,
			cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
			timeoutInterval: timeoutInterval
		)
		
		urlRequest.httpMethod = request.httpMethod.rawValue
		
		if (request.bodyEncoding == nil) {
			urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		} else {
			try configureParameters(
				bodyParameters: request.parameters,
				bodyEncoding: request.bodyEncoding!,
				urlParameters: request.urlParameters,
				request: &urlRequest
			)
		}
		
		if let additionalHeaders = request.headers {
			addAdditionalHeaders(additionalHeaders, request: &urlRequest)
		}
		
		return urlRequest
	}
	
	fileprivate func configureParameters(
		bodyParameters: Parameters?,
		bodyEncoding: ParameterEncoding,
		urlParameters: Parameters?,
		request: inout URLRequest
	) throws {
		
		try bodyEncoding.encode(
			urlRequest: &request,
			bodyParameters: bodyParameters, urlParameters: urlParameters
		)
	}
	
	fileprivate func addAdditionalHeaders(
		_ additionalHeaders: HTTPHeaders?,
		request: inout URLRequest
	) {
		guard let headers = additionalHeaders else { return }
		for (key, value) in headers {
			request.setValue(value, forHTTPHeaderField: key)
		}
	}
}
