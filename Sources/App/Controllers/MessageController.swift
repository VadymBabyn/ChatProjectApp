import Fluent
import Vapor
import Foundation
// Структури для відповіді від OpenAI API
struct OpenAIResponse: Content {
    var choices: [Choice]
    
    struct Choice: Content {
        var message: MessageContent
    }

    struct MessageContent: Content {
        var content: String
    }
}

// Структури для запиту до OpenAI API
struct OpenAIMessage: Content {
    var role: String
    var content: String
}

struct OpenAIRequestBody: Content {
    let model: String
    let messages: [OpenAIMessage]
    let max_tokens: Int
    let temperature: Double
}

struct MessageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let messages = routes.grouped("messages")

        messages.post("ai", use: createMessageWithAIResponse)
        // Отримати всі повідомлення для конкретного чату
        messages.get(":chatId", use: self.getMessagesByChatId)

        // Створити нове повідомлення
        messages.post(use: self.create)
        
        // Видалити повідомлення за ID
        messages.group(":todoID") { message in
            message.delete(use: self.delete)
        }
    }
    
    // Отримати всі повідомлення для конкретного чату
    @Sendable
    func getMessagesByChatId(req: Request) async throws -> [MessageDTO] {
        guard let chatIdString = req.parameters.get("chatId"),
              let chatId = UUID(uuidString: chatIdString) else {
            throw Abort(.badRequest, reason: "Invalid or missing chatId")
        }
        
        // Шукаємо всі повідомлення для цього chatId
        let messages = try await Message.query(on: req.db)
            .filter(\.$chatId == chatId)  // Фільтруємо за chatId
            .all()

        return messages.map { $0.toDTO() }
    }

    // Створити нове повідомлення
    @Sendable
    func create(req: Request) async throws -> MessageDTO {
        // Декодуємо дані з запиту (отримуємо content та chatId)
        let messageDTO = try req.content.decode(MessageDTO.self)
        
        // Створюємо нове повідомлення, передаючи chatId та content
        let message = Message(
            sender: "ChatGPT", // Можна задати дефолтне значення
            recipient: "User", // Можна задати дефолтне значення
            content: messageDTO.content ?? "", // content з запиту
            chatId: messageDTO.chatId // chatId з запиту
        )
        
        // Зберігаємо повідомлення в базі
        try await message.save(on: req.db)
        
        // Повертаємо DTO з новим повідомленням (включаючи генероване id та createdAt)
        return message.toDTO() 
    }

    // Видалити повідомлення
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let message = try await Message.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await message.delete(on: req.db)
        return .noContent
    }
    @Sendable
    func createMessageWithAIResponse(req: Request) async throws -> MessageDTO {
        let message = try req.content.decode(Message.self)
        
        let messageDTO = try req.content.decode(MessageDTO.self)
        
        // Створюємо нове повідомлення, передаючи chatId та content
        let userMessage = Message(
            sender: "User", // Можна задати дефолтне значення
            recipient: "ChatGPT", // Можна задати дефолтне значення
            content: messageDTO.content ?? "", // content з запиту
            chatId: messageDTO.chatId // chatId з запиту
        )
        try await userMessage.save(on: req.db)
        // Формуємо повідомлення для OpenAI API
        let openAIMessage = OpenAIMessage(
            role: "user",  // Роль користувача
            content: message.content  // Вміст повідомлення
        )

        let openAIRequestBody = OpenAIRequestBody(
            model: "gpt-4",
            messages: [openAIMessage],  // Включаємо повідомлення користувача в масив
            max_tokens: 100,
            temperature: 0.7
        )
        let openAIKey: String

        do {
            openAIKey = try readSecrets() ?? "default-key-if-not-set"
        } catch {
            fatalError("Could not load OpenAI API key: \(error)")
        }
        // Виконуємо запит до OpenAI API
        let openAIResponse = try await req.client.post("https://api.openai.com/v1/chat/completions") {
            try $0.content.encode(openAIRequestBody)
            $0.headers.add(name: .authorization, value: "Bearer  \(openAIKey)")
        }

        // Перевіряємо статус відповіді
        guard openAIResponse.status == .ok else {
            throw Abort(.internalServerError, reason: "Failed to get response from OpenAI. Status: \(openAIResponse.status.code)")
        }
        
        // Декодуємо відповідь від OpenAI
        let aiResponse = try openAIResponse.content.decode(OpenAIResponse.self)

        // Отримуємо текст з відповіді
        let aiMessageContent = aiResponse.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No response from AI"

        // Створюємо нове повідомлення
        let newMessage = Message(
            sender: "ChatGPT",
            recipient: "User",
            content: aiMessageContent,
            chatId: message.chatId
        )

        // Зберігаємо повідомлення в базі
        try await newMessage.save(on: req.db)

        // Повертаємо DTO
        return newMessage.toDTO()
    }
}
