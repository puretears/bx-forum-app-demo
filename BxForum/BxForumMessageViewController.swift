//
//  BxForumMessageViewController.swift
//  BxForum
//
//  Created by Mars on 2018/10/6.
//  Copyright © 2018 Mars. All rights reserved.
//

import UIKit
import PromiseKit

class BxForumMessageViewController: UIViewController {
  var forumId: Int
  var spinner: UIView!
  var messageList: UITableView!
  var messageContext: MessageContext!

  init(forumId: Int) {
    self.forumId = forumId
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white
    
    // Title
    self.title = "Loading message..."
    
    if self.messageContext != nil {
      initUI()
    }
    else {
      fetchMessageData()
    }
  }
  
  func initUI() {
    self.title = self.messageContext.forum.name
    
    // Forum list
    self.messageList = UITableView()
    self.messageList.translatesAutoresizingMaskIntoConstraints = false
    self.messageList.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
    self.messageList.dataSource = self
    self.messageList.delegate = self
    self.view.addSubview(messageList)
    
    NSLayoutConstraint.activate([
      messageList.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 25.0),
      messageList.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
      messageList.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
      messageList.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
    ].compactMap {$0})
  }
  
  func fetchMessageData() {
    let url = URL(string: "http://localhost:8080/forums/\(forumId)/messages")!
    let messageContext = URLSession.shared
      .dataTask(.promise, with: url)
      .map(on: DispatchQueue.global()) {
        response -> MessageContext in
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
          let data = try decoder.singleValueContainer().decode(String.self)
          let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
          
          return formatter.date(from: data)!
        })
        
        return try decoder.decode(MessageContext.self, from: response.data)
    }
    
    firstly {
      () -> Promise<MessageContext> in
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      self.displaySpinner()
      return messageContext
    }.done {
      (context: MessageContext) in
      self.messageContext = context
      self.initUI()
      self.view.setNeedsLayout()
    }.ensure {
        self.removeSpinner()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }.catch { error in
        print(error)
    }
  }
  
  func displaySpinner() {
    self.spinner = UIView(frame: view.bounds)
    self.spinner.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.5)
    
    let ai = UIActivityIndicatorView(style: .whiteLarge)
    ai.startAnimating()
    ai.center = self.spinner.center
    
    self.spinner.addSubview(ai)
    self.view.addSubview(self.spinner)
  }
  
  func removeSpinner() {
    self.spinner.removeFromSuperview()
  }
}

extension BxForumMessageViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.messageContext.messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
    cell.textLabel!.text = self.messageContext.messages[indexPath.row].content
    cell.accessoryType = .disclosureIndicator
    return cell
  }
}

extension BxForumMessageViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.messageList.deselectRow(at: indexPath, animated: true)
    
    let replyVC = BxForumReplyViewController(forumId: forumId, messageId: indexPath.row + 1)
    self.navigationController?.pushViewController(replyVC, animated: true)
  }
}

