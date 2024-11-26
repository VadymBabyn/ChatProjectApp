import Vapor

func routes(_ app: Application) throws {

    // Тестування зв'язку з базою даних (додатково)
    app.get("test", "database") { req async -> String in
        do {
            // Перевіряємо, чи зможемо отримати перше повідомлення з бази даних
            let message = try await Message.query(on: req.db).first()
            if let message = message {
                return "Database is connected. First message: \(message.content)"
            } else {
                return "Database is connected, but no messages found."
            }
        } catch {
            return "Error connecting to the database: \(error.localizedDescription)"
        }
    }
    // Реєстрація MessageController
    try app.register(collection: ChatController())
    try app.register(collection: MessageController())
}
