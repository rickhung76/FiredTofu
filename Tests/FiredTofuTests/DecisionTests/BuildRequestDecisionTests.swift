import XCTest
@testable import FiredTofu


class BuildRequestDecisionTests: XCTestCase {
    
    struct TestResponseModel: Decodable {
        
    }
    
	class TestRequest: Request {
		
        typealias Response = TestResponseModel
        
        var formatRequest: URLRequest? = nil
        
        var rawResponse: RawResponseTuple? = nil
		
		var baseURL: String {
			return "https://test.com"
		}
        
        var path: String {
            return "/test"
        }
        
        var httpMethod: HTTPMethod {
            return .post
        }
        
        var parameters: Parameters? {
            return nil
        }
        
        var urlParameters: Parameters? {
            return nil
        }
        
        var bodyEncoding: ParameterEncoding? {
            return nil
        }
        
        var headers: HTTPHeaders? {
            return nil
        }
        
        var multiDomain: MultiDomain = .init(URLs: ["https://unitest.BuildRequestDecision"])
    }
    
    var request = TestRequest()
    let decision = BuildRequestDecision()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShouldApply() {
        let shouldApply = decision.shouldApply(request: request)
        XCTAssertEqual(shouldApply, true)
    }

    
    func testApply() {
        decision.apply(request: request, decisions: []) { (action) in
            switch action {
            case .continueWithRequest(let request):
                print(request)
                guard let _ = request.formatRequest else {
                    XCTAssert(false, "Empty formate request")
                    return
                }
                XCTAssert(true)
            case .restartWith(let request, let decisions):
                print(request)
                print(decisions)
                XCTAssert(false, "decision handler wrong state: .restartWith( \(request), \(decisions))")
            case .done(let request):
                print(request)
                XCTAssert(false, "decision handler wrong state: .done( \(request))")
            case .errored(let error):
                print(error)
                XCTAssert(false, error.localizedDescription)
            }
        }
    }

}
