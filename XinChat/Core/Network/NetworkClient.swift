import Alamofire
import Foundation

/// 网络客户端抽象，用于隔离 Alamofire 并支持在测试中注入 Mock 实现。
protocol NetworkClientProtocol {
    /// 请求指定 Endpoint，并将响应解码为目标类型。
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
}

/// 基于 Alamofire 的统一网络请求实现。
/// 负责 URL 组装、参数编码、状态码校验、JSON 解码和错误映射。
final class NetworkClient: NetworkClientProtocol {
    private let baseURL: URL
    private let session: Session

    init(
        // 演示环境使用 JSONPlaceholder；正式项目应从环境配置中注入该地址。
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
            // ViewModel 会直接驱动 UIKit，因此统一在主线程回调。
            DispatchQueue.main.async { completion(result) }
        }
    }
}
