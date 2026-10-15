import Foundation

protocol AuthRepositoryProtocol {
    func login(
        username: String,
        password: String,
        completion: @escaping (Result<AuthenticatedSession, NetworkError>) -> Void
    )

    func sendEmailCode(
        email: String,
        completion: @escaping (Result<String, NetworkError>) -> Void
    )

    func loginByEmail(
        email: String,
        code: String,
        completion: @escaping (Result<AuthenticatedSession, NetworkError>) -> Void
    )

    func sendPasswordResetCode(
        email: String,
        completion: @escaping (Result<String, NetworkError>) -> Void
    )

    func resetPassword(
        email: String,
        code: String,
        newPassword: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
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

    func sendEmailCode(
        email: String,
        completion: @escaping (Result<String, NetworkError>) -> Void
    ) {
        networkClient.request(
            AuthAPI.sendEmailCode(email: email),
            responseType: GenericNetworkResponse<String>.self
        ) { result in
            switch result {
            case let .success(response):
                completion(.success(response.data ?? response.message ?? "验证码已发送"))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func loginByEmail(
        email: String,
        code: String,
        completion: @escaping (Result<AuthenticatedSession, NetworkError>) -> Void
    ) {
        // 先尝试调用服务端的邮箱验证码登录端点
        networkClient.request(
            AuthAPI.loginByEmail(email: email, code: code),
            responseType: LoginResponse.self
        ) { [weak self] result in
            switch result {
            case let .success(response):
                completion(.success(response.session))
            case let .failure(error):
                // 如果服务端暂未提供 /auth/login/email（如返回 404 或 405），
                // 优雅降级到自动注册（符合无注册页、自动注册产品逻辑）
                if case let .server(statusCode, _) = error, statusCode == 404 || statusCode == 405 {
                    self?.fallbackAutoRegister(email: email, code: code, completion: completion)
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    private func fallbackAutoRegister(
        email: String,
        code: String,
        completion: @escaping (Result<AuthenticatedSession, NetworkError>) -> Void
    ) {
        // 自动注册：服务端如果已有邮箱会返回 409，未注册则自动注册并返回 session
        let autoPassword = UUID().uuidString
        networkClient.request(
            AuthAPI.register(email: email, code: code, password: autoPassword),
            responseType: LoginResponse.self
        ) { [weak self] regResult in
            switch regResult {
            case let .success(response):
                completion(.success(response.session))
            case let .failure(regError):
                if case let .server(statusCode, msg) = regError, statusCode == 409 {
                    // 该邮箱已注册过，提示使用密码登录
                    completion(.failure(.server(statusCode: 409, message: "该邮箱已注册，请使用密码登录或找回密码")))
                } else {
                    completion(.failure(regError))
                }
            }
        }
    }

    func sendPasswordResetCode(
        email: String,
        completion: @escaping (Result<String, NetworkError>) -> Void
    ) {
        networkClient.request(
            AuthAPI.sendPasswordResetCode(email: email),
            responseType: GenericNetworkResponse<String>.self
        ) { result in
            switch result {
            case let .success(response):
                completion(.success(response.data ?? response.message ?? "验证码已发送"))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func resetPassword(
        email: String,
        code: String,
        newPassword: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        networkClient.request(
            AuthAPI.updatePassword(email: email, code: code, newPassword: newPassword),
            responseType: GenericNetworkResponse<Bool>.self
        ) { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
