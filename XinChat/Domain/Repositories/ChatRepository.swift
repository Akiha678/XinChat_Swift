import Foundation

protocol ChatRepositoryProtocol {
    func fetchContacts(completion: @escaping (Result<[Contact], NetworkError>) -> Void)
    func conversations() -> [Conversation]
}

final class ChatRepository: ChatRepositoryProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func fetchContacts(completion: @escaping (Result<[Contact], NetworkError>) -> Void) {
        networkClient.request(ChatAPI.contacts, responseType: [Contact].self, completion: completion)
    }

    func conversations() -> [Conversation] {
        [
            Conversation(id: UUID(), name: "产品研发群", preview: "林夕：新版本已经提交测试", time: "10:28", unreadCount: 3, colorSeed: 0),
            Conversation(id: UUID(), name: "陈晨", preview: "好的，下午会议见", time: "09:42", unreadCount: 0, colorSeed: 1),
            Conversation(id: UUID(), name: "设计协作群", preview: "你收到了一张图片", time: "昨天", unreadCount: 8, colorSeed: 2),
            Conversation(id: UUID(), name: "系统通知", preview: "欢迎使用 XinChat", time: "星期五", unreadCount: 0, colorSeed: 3)
        ]
    }
}
