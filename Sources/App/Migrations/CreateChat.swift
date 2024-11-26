import Fluent

struct CreateChat: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("chats")
            .field("id", .uuid, .identifier(auto: false), .custom("DEFAULT gen_random_uuid()"))
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("chats").delete()
    }
}
