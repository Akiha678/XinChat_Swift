import Alamofire
import Foundation

protocol NetworkClientProtocol {
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
}

final class NetworkClient: NetworkClientProtocol {
    private let baseURL: URL
    private let session: Session

    init(
        baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!,
        session: Session = .default
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        let url = baseURL.appending(path: endpoint.path)
        session.request(
            url,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: endpoint.method == .get ? URLEncoding.default : JSONEncoding.default
        )
        .validate(statusCode: 200..<300)
        .responseDecodable(of: responseType) { response in
            let result: Result<T, NetworkError>
            switch response.result {
            case let .success(value):
                result = .success(value)
            case let .failure(error):
                if let statusCode = response.response?.statusCode {
                    result = .failure(.server(statusCode: statusCode))
                } else {
                    result = .failure(.transport(error))
                }
            }
            DispatchQueue.main.async { completion(result) }
        }
    }
}
