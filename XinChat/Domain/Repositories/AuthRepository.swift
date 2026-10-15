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

    /// 发送邮箱验证码（全自动适配：新用户发注册码，老用户发验证码，不强迫老用户改走密码）
    func sendEmailCode(
        email: String,
        completion: @escaping (Result<String, NetworkError>) -> Void
    ) {
        // 第一优先级：尝试通用的邮箱登录发码接口
        networkClient.request(
            AuthAPI.sendEmailLoginCode(email: email),
            responseType: GenericNetworkResponse<String>.self
        ) { [weak self] result in
            switch result {
            case let .success(response) where response.code == 1000 || response.code == 200:
                completion(.success(response.data ?? response.message ?? "验证码已发送到邮箱"))
            default:
                // 若服务端尚未部署通用发码端点，自适应平滑降级
                self?.sendEmailCodeFallback(email: email, completion: completion)
            }
        }
    }

    private func sendEmailCodeFallback(
        email: String,
        completion: @escaping (Result<String, NetworkError>) -> Void
    ) {
        networkClient.request(
            AuthAPI.sendRegisterCode(email: email),
            responseType: GenericNetworkResponse<String>.self
        ) { [weak self] regResult in
            switch regResult {
            case let .success(response):
                if response.code == 409 || response.message?.contains("已注册") == true {
                    // 该邮箱已注册过：老用户同样需要验证码登录！自动通过邮箱验证码服务发送验证码
                    self?.sendPasswordResetCode(email: email, completion: completion)
                } else if let code = response.code, code != 1000 && code != 200 {
                    completion(.failure(.server(statusCode: code, message: response.message ?? "发送失败")))
                } else {
                    completion(.success(response.data ?? response.message ?? "验证码已发送到邮箱"))
                }
            case .failure:
                // 失败重试已注册通道
                self?.sendPasswordResetCode(email: email, completion: completion)
            }
        }
    }

    /// 邮箱验证码登录（新用户未注册自动注册，已注册直接登录）
    func loginByEmail(
        email: String,
        code: String,
        completion: @escaping (Result<AuthenticatedSession, NetworkError>) -> Void
    ) {
        // 请求服务端的邮箱验证码登录端点
        networkClient.request(
            AuthAPI.loginByEmail(email: email, code: code),
            responseType: LoginResponse.self
        ) { [weak self] result in
            switch result {
            case let .success(response):
                completion(.success(response.session))
            case let .failure(error):
                if case let .server(statusCode, _) = error, statusCode == 404 || statusCode == 405 {
                    // 服务端暂未部署 POST /auth/login/email 时的降级兜底
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
        let autoPassword = UUID().uuidString
        networkClient.request(
            AuthAPI.register(email: email, code: code, password: autoPassword),
            responseType: LoginResponse.self
        ) { regResult in
            switch regResult {
            case let .success(response):
                completion(.success(response.session))
            case let .failure(regError):
                if case let .server(statusCode, msg) = regError, statusCode == 409 {
                    completion(.failure(.server(statusCode: 409, message: "该邮箱为已注册账号，后端尚未配置老用户邮箱验证码直登接口（POST /auth/login/email），请先添加后端接口或使用密码登录")))
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
                if let code = response.code, code != 1000 && code != 200 {
                    let msg = response.message ?? "操作失败"
                    completion(.failure(.server(statusCode: code, message: msg)))
                } else {
                    completion(.success(response.data ?? response.message ?? "验证码已发送到邮箱"))
                }
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
            case let .success(response):
                if let code = response.code, code != 1000 && code != 200 {
                    let msg = response.message ?? "重置失败"
                    completion(.failure(.server(statusCode: code, message: msg)))
                } else {
                    completion(.success(()))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
