import Fluent

struct CreateMessage: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("messages")
            .field("id", .uuid, .identifier(auto: false), .custom("DEFAULT gen_random_uuid()"))
            .field("sender", .string, .required)
            .field("recipient", .string, .required)
            .field("content", .string, .required)
            .field("created_at", .datetime, .custom("DEFAULT CURRENT_TIMESTAMP"))
            .field("chat_id", .uuid, .references("chats", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("messages").delete()
    }
}
