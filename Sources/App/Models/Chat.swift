import Fluent
import Foundation
import Vapor

final class Chat: Model, Content, @unchecked Sendable {
    static let schema = "chats"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() {}

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
