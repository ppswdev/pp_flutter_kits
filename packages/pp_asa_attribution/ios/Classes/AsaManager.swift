import AdServices
import AppTrackingTransparency

class AsaManager {
    static func attributionToken() -> String? {
        if #available(iOS 14.3, *) {
            do {
                let attributionToken = try AAAttribution.attributionToken()
                return attributionToken
            } catch {
                print("Failed to get attribution token: \(error.localizedDescription)")
            }
        } else {
            print("AAAttribution is not available on this iOS version.")
        }
        return nil
    }
    
    static func requestAttribution(complete: @escaping (([String: Any]?, Error?) -> Void)) {
        if #available(iOS 14.3, *) {
            guard let token = attributionToken(), !token.isEmpty else {
                let error = NSError(domain: "app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve attribution token"])
                complete(nil, error)
                return
            }
            requestAttribution(withToken: token, complete: complete)
        } else {
            let error = NSError(domain: "app", code: -1, userInfo: [NSLocalizedDescriptionKey: "ATTracking Not Allowed"])
            complete(nil, error)
        }
    }
    
    static func requestAttribution(withToken token: String, complete: @escaping (([String: Any]?, Error?) -> Void)) {
        let url = "https://api-adservices.apple.com/api/v1/"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = token.data(using: .utf8)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    complete(nil, error)
                }
                return
            }
            if let data = data {
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    DispatchQueue.main.async {
                        complete(result ?? [:], nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        complete(nil, error)
                    }
                }
            }
        }
        dataTask.resume()
    }
}
