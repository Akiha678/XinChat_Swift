import Foundation

/// 通讯业务的数据访问边界。
/// Presentation 层只依赖该协议，不感知数据来自网络、数据库还是本地缓存。
protocol ChatRepositoryProtocol {
    /// 从远端获取联系人列表。
    func fetchContacts(completion: @escaping (Result<[Contact], NetworkError>) -> Void)
    /// 获取当前会话列表。
    func conversations() -> [Conversation]
}

/// 通讯数据仓库的默认实现。
final class ChatRepository: ChatRepositoryProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func fetchContacts(completion: @escaping (Result<[Contact], NetworkError>) -> Void) {
        networkClient.request(ChatAPI.contacts, responseType: [Contact].self, completion: completion)
    }

    func conversations() -> [Conversation] {
        // 当前为 UI 演示数据，接入后端后可替换为本地数据库与增量同步结果。
        [
            Conversation(id: UUID(), name: "产品研发群", preview: "林夕：新版本已经提交测试", time: "10:28", unreadCount: 3, colorSeed: 0),
            Conversation(id: UUID(), name: "陈晨", preview: "好的，下午会议见", time: "09:42", unreadCount: 0, colorSeed: 1),
            Conversation(id: UUID(), name: "设计协作群", preview: "你收到了一张图片", time: "昨天", unreadCount: 8, colorSeed: 2),
            Conversation(id: UUID(), name: "系统通知", preview: "欢迎使用 XinChat", time: "星期五", unreadCount: 0, colorSeed: 3)
        ]
    }
}
