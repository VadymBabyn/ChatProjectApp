import Fluent
import struct Foundation.UUID

final class Message: Model, @unchecked Sendable {
    static let schema = "messages" // Назва таблиці у базі даних

    @ID(key: .id)
    var id: UUID?

    @Field(key: "sender")
    var sender: String

    @Field(key: "recipient")
    var recipient: String

    @Field(key: "content")
    var content: String

    @Field(key: "created_at")
    var createdAt: Date?

    @Field(key: "chat_id")
    var chatId: UUID?

    init() {}

    init(id: UUID? = nil, sender: String, recipient: String, content: String, createdAt: Date? = nil, chatId: UUID?) {
        self.id = id
        self.sender = sender
        self.recipient = recipient
        self.content = content
        self.createdAt = Date()
        self.chatId = chatId
    }

    func toDTO() -> MessageDTO {
        .init(
            id: self.id,
            sender: self.sender,
            recipient: self.recipient,
            content: self.content,
            createdAt: self.createdAt,
            chatId: self.chatId
        )
    }
}


