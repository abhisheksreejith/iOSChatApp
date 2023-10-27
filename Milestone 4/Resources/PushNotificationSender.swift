//
//  PushNotificationSender.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 14/10/23.
//
import Foundation
class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String, senderID: String) {
        let urlString  = "https://fcm.googleapis.com/fcm/send"
        let url = URL(string: urlString)!
        let paramString: [String: Any] = ["to": token, "notification": ["title": title, "body": body], "data": ["user": senderID]]
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAcK75WUQ:APA91bHnbHiaTGosZs8Tk2qeCau97sf1g0aNihgiZunbPxdIodHdrb-_YnZKOPkF4UKezGn66b_dFpITybBGBlktgDHKJFhfcGPCzQa9uLgtGv0-Oa4tajD328gsguHY9KqM4dxhgSqX",
        forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, _, _ in
            do {
                if let jsonData = data {
                    // here a change was made
                    if let jsonDataDict = try JSONSerialization
                        .jsonObject(with: jsonData,
                                    options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? [String: AnyObject] {
                        NSLog("Recieved Data:\n\(jsonDataDict)")
                    }
                }
            } catch let err as NSError {
                print(err.localizedDescription)
            }
        }
        task.resume()
    }
}
