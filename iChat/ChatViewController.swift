//
//  ChatViewController.swift
//  iChat
//
//  Created by Mohamed Sobhi Fouda on 6/26/18.
//  Copyright © 2016 CareerFoundry. All rights reserved.
//

import UIKit
import Firebase
import MessageKit

class ChatViewController: MessagesViewController {
    
    var messages: [MessageType] = []
    var ref: DatabaseReference!
    private var databaseHandle: DatabaseHandle!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        messages.removeAll()
        databaseHandle = ref.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
            if let value = snapshot.value as? [String:AnyObject] {
                let id = value["senderId"] as! String
                let text = value["text"] as! String
                let name = value["senderDisplayName"] as! String
                
                let sender = Sender(id: id, displayName: name)
                let message = UserMessage(text: text, sender: sender, messageId: id, date: Date())
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.ref.removeObserver(withHandle: databaseHandle)
    }
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            AuthenticationManager.sharedInstance.loggedIn = false
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
    }
}

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        let senderID = AuthenticationManager.sharedInstance.userId!
        let senderDisplayName = AuthenticationManager.sharedInstance.userName!
        
        return Sender(id: senderID, displayName: senderDisplayName)
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let messageRef = ref.child("messages").childByAutoId()
        let message = [
            "text": text,
            "senderId": currentSender().id,
            "senderDisplayName": currentSender().displayName
        ]
        
        messageRef.setValue(message)
        inputBar.inputTextView.text = String()
    }
}

extension ChatViewController: MessagesDisplayDelegate {//, TextMessageDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if isFromCurrentSender(message: message) {
            return .orange
        } else {
            return .lightGray
        }
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if isFromCurrentSender(message: message) {
            return .white
        } else {
            return .darkText
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if isFromCurrentSender(message: message) {
            return .bubbleTail(.bottomRight, .curved)
        } else {
            return .bubbleTail(.bottomLeft, .curved)
        }
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        if isFromCurrentSender(message: message) {
            return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
        }
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
}
