import Fluent
import Vapor

struct MessageDTO: Content {
    var id: UUID?
    var sender: String?
    var recipient: String?
    var content: String?
    var createdAt: Date??
    var chatId: UUID?
    
    func toModel() -> Message {
        let model = Message()
        
        model.id = self.id
        if let sender = self.sender {
            model.sender = sender
        }
        if let recipient = self.recipient {
            model.recipient = recipient
        }
        if let content = self.content {
            model.content = content
        }
        if let createdAt = self.createdAt {
            model.createdAt = createdAt
        }
        model.chatId = self.chatId
        return model
    }
}

