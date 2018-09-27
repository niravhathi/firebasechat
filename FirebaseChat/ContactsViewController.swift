//
//  ContactsViewController.swift
//  FirebaseChat
//
//  Created by DSPL on 26/09/18.
//  Copyright © 2018 Nirav Hathi. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, FetchData {

    @IBOutlet weak var tableView: UITableView!
    let CHAT_SEGUE = "chatSegue"
    
    var contacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        DatabaseHelper.Instance.delegate = self
        
        DatabaseHelper.Instance.getContacts()
        
        // Do any additional setup after loading the view.
    }
    
    func dataReceived(contacts: [Contact]) {
        self.contacts = contacts
        
        for (index,contact) in contacts.enumerated() {
            if contact.id == AuthHelper.Instance.userId() {
                
                AuthHelper.Instance.userName = contact.name
                self.contacts.remove(at: index)
                
            }
        }
        
        tableView.reloadData()
    }

    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        if AuthHelper.Instance.logOut() {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == CHAT_SEGUE)
        {
            let chatViewController =  segue.destination as! ChatViewController
            chatViewController.contact =  sender as! Contact
        }
    }
}

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: CHAT_SEGUE, sender: contacts[indexPath.row])
    }
    
}

extension ContactsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = contacts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = contact.name
        return cell
    }
}
