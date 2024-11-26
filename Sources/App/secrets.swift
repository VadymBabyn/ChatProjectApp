import Foundation

// Глобальна функція для зчитування API-ключа з Secrets.json
func readSecrets() throws -> String? {
    let url = URL(fileURLWithPath: "./Secrets.json") // або точний шлях до файлу
    let data = try Data(contentsOf: url)
    let json = try JSONSerialization.jsonObject(with: data, options: [])
    if let dictionary = json as? [String: String] {
        return dictionary["openai_api_key"]
    }
    return nil
}
