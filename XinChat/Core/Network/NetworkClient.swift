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
    private struct ServerErrorBody: Decodable { let message: String? }
    private let customBaseURL: URL?
    private let session: Session

    /// 动态获取当前激活的 Base URL（未指定 customBaseURL 时实时跟随 AppEnvironment.apiBaseURL）
    private var activeBaseURL: URL {
        customBaseURL ?? AppEnvironment.apiBaseURL
    }

    init(
        baseURL: URL? = nil,
        session: Session = .default
    ) {
        self.customBaseURL = baseURL
        self.session = session
    }

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        let url = activeBaseURL.appending(path: endpoint.path)
        var headers = HTTPHeaders()
        if endpoint.requiresAuthentication, let token = AppSession.accessToken {
            headers.add(.authorization(bearerToken: token))
        }
        session.request(
            url,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: endpoint.method == .get ? URLEncoding.default : JSONEncoding.default,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .responseDecodable(of: responseType) { response in
            let result: Result<T, NetworkError>
            switch response.result {
            case let .success(value):
                result = .success(value)
            case let .failure(error):
                if let statusCode = response.response?.statusCode {
                    let message = response.data.flatMap {
                        try? JSONDecoder().decode(ServerErrorBody.self, from: $0).message
                    }
                    result = .failure(.server(statusCode: statusCode, message: message))
                } else {
                    result = .failure(.transport(error))
                }
            }
            // ViewModel 会直接驱动 UIKit，因此统一在主线程回调。
            DispatchQueue.main.async { completion(result) }
        }
    }
}
