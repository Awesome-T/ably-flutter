import Foundation

class Notification: NSObject {
    @objc
    let title: String?;
    @objc
    let body: String?;
    
    init(title: String?, body: String?) {
      self.title = title
      self.body = body
    }
    
    convenience init?(from userInfo: [AnyHashable : Any]) {
        if let aps = userInfo["aps"] as? [AnyHashable: Any] {
            if let alert = aps["alert"] as? [AnyHashable: Any] {
                let title = alert["title"] as? String
                let body = alert["body"] as? String
                self.init(title: title, body: body)
            } else if let title = aps["alert"] as? String {
                self.init(title: title, body: nil)
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    }
}
