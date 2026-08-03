import Foundation

protocol AuthRepositoryProtocol {
    func login(
        username: String,
        password: String,
        completion: @escaping (Result<AuthenticatedSession, NetworkError>) -> Void
    )
}

/// 认证数据仓库，隔离页面与具体网络实现。
final class AuthRepository: AuthRepositoryProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func login(
        username: String,
        password: String,
        completion: @escaping (Result<AuthenticatedSession, NetworkError>) -> Void
    ) {
        networkClient.request(
            AuthAPI.login(username: username, password: password),
            responseType: LoginResponse.self
        ) { result in
            completion(result.map(\.session))
        }
    }
}
