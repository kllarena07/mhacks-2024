
//
//  TranslationService.swift
//  MHacks24_iOS
//
//  Created by Gabriel Push on 9/28/24.
//
import Foundation
class TranslationService: ObservableObject {
    private let apiKey = Bundle.main.infoDictionary?["API_KEY"]  as? String ?? ""
    func translate(text: String, toLanguage: String, completion:  @escaping  (Result<String, Error>) -> Void) {
        let endpoint = "https://api.openai.com/v1/chat/completions"
        guard let url = URL(string: endpoint) else { return }
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Set headers
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Prepare the messages
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are a translation assistant."],
            ["role": "user", "content": "Translate the following text to \(toLanguage): \(text)"]
        ]
        // Prepare the parameters
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo", // Use "gpt-3.5-turbo" or "gpt-4" if available
            "messages": messages,
            "temperature": 0.5
        ]
        // Set the HTTP body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        // Create the data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let error = NSError(domain: "TranslationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }
            // Parse the response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let translatedText = message["content"] as? String {
                    completion(.success(translatedText.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else {
                    let error = NSError(domain: "TranslationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
