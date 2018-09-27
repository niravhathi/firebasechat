//
//  MessageHandler.swift
//  FirebaseChat
//
//  Created by DSPL on 26/09/18.
//  Copyright © 2018 Nirav Hathi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol MessageHandlerDelegate: class {
    func messageReceived(senderId: String, senderName: String, text: String)
    func mediaReceived(senderId: String, senderName: String, mediaUrl: String)
}

class MessageHandler {
    private static let _instance = MessageHandler()
    
    private init() {
        
    }
    
    weak var delegate: MessageHandlerDelegate?
    
    static var Instance: MessageHandler {
        return _instance
    }
    
    func sendMessage(senderId: String, senderName: String, text: String,stringChatID:String) {
        let data: [String: Any] = [Constants.SENDER_ID: senderId, Constants.SENDER_NAME: senderName, Constants.TEXT: text]
        
        DatabaseHelper.Instance.messagesRef.child(stringChatID).childByAutoId().setValue(data)
        
    }
    
    func sendMediaMessage(senderId: String, senderName: String, url: String,stringChatID:String) {
        let data: [String: Any] = [Constants.SENDER_ID: senderId, Constants.SENDER_NAME: senderName, Constants.URL: url]
        
        DatabaseHelper.Instance.messagesRef.child(stringChatID).childByAutoId().setValue(data)
    }
    
    func sendMedia(image: Data?, video: URL?, senderId: String, senderName: String,stringChatID:String) {
        if image != nil {
            DatabaseHelper.Instance.imageStorageRef.child(senderId + "\(NSUUID().uuidString).jpg").put(image!, metadata: nil, completion: { (metadata: FIRStorageMetadata?, error: Error?) in
                guard error == nil else { return }
                self.sendMediaMessage(senderId: senderId, senderName: senderName, url: String(describing: metadata!.downloadURL()!), stringChatID: stringChatID)
            })
        } else  {
            DatabaseHelper.Instance.videoStorageRef.child(senderId + "\(NSUUID().uuidString)").putFile(video!, metadata: nil, completion: { (metadata: FIRStorageMetadata?, error: Error?) in
                guard error == nil else { return }
                self.sendMediaMessage(senderId: senderId, senderName: senderName, url: String(describing: metadata!.downloadURL()!), stringChatID: stringChatID)
            })
        }
    }
    
    func messageExists()
    {
          
    }
    func observeMessages(_ stringChatID:String) {
     Constants.CHAT_OBSERVER = DatabaseHelper.Instance.messagesRef.child(stringChatID).observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let senderId = data[Constants.SENDER_ID] as? String {
                    if let senderName = data[Constants.SENDER_NAME] as? String {
                        if let text = data[Constants.TEXT] as? String {
                              print(Constants.CHAT_OBSERVER)
                            self.delegate?.messageReceived(senderId: senderId, senderName: senderName, text: text)
                        }
                        else if let fileUrl = data[Constants.URL] as? String {
                            self.delegate?.mediaReceived(senderId: senderId, senderName: senderName, mediaUrl: fileUrl)
                        }
                    }
                    
                }
            }
        }
    }
    
    func observeMediaMessages() {
        DatabaseHelper.Instance.mediaMessagesRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let id = data[Constants.SENDER_ID] as? String {
                    if let senderName = data[Constants.SENDER_NAME] as? String {
                        if let fileUrl = data[Constants.URL] as? String {
                            self.delegate?.mediaReceived(senderId: id, senderName: senderName, mediaUrl: fileUrl)
                        }
                    }
                }
            }
        }
    }
}
