import Vapor
import Fluent

struct ChatController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let chats = routes.grouped("chats")
        chats.get(use: index)
        chats.get(":chatId", use: getChat)
        chats.post(use: create)
        chats.put(":chatId", use: update)
        chats.delete(":chatId", use: delete)
    }

    /// Отримання всіх чатів
    func index(req: Request) async throws -> [Chat] {
        try await Chat.query(on: req.db).all()
    }

    /// Отримання чату за ID
    func getChat(req: Request) async throws -> Chat {
        guard let chatId = req.parameters.get("chatId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing chat ID.")
        }
        guard let chat = try await Chat.find(chatId, on: req.db) else {
            throw Abort(.notFound, reason: "Chat not found.")
        }
        return chat
    }

    /// Створення нового чату
    func create(req: Request) async throws -> Chat {
        let chat = try req.content.decode(Chat.self)
        try await chat.save(on: req.db)
        return chat
    }

    /// Оновлення чату
    func update(req: Request) async throws -> Chat {
        guard let chatId = req.parameters.get("chatId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing chat ID.")
        }
        guard let existingChat = try await Chat.find(chatId, on: req.db) else {
            throw Abort(.notFound, reason: "Chat not found.")
        }
        let updatedChat = try req.content.decode(Chat.self)
        existingChat.name = updatedChat.name
        try await existingChat.save(on: req.db)
        return existingChat
    }

    /// Видалення чату
    func delete(req: Request) async throws -> HTTPStatus {
        guard let chatId = req.parameters.get("chatId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing chat ID.")
        }
        guard let chat = try await Chat.find(chatId, on: req.db) else {
            throw Abort(.notFound, reason: "Chat not found.")
        }
        try await chat.delete(on: req.db)
        return .noContent
    }
}
