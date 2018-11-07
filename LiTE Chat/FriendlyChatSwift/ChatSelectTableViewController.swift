//
//  ChatSelectTableViewController.swift
//  FriendlyChatSwift
//
//  Created by osama on 10/3/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class ChatSelectTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var privateBtn: UIBarButtonItem!
    @IBOutlet weak var publicBtn: UIBarButtonItem!
    
    @IBOutlet weak var table1: UITableView!
    @IBOutlet weak var table3: UITableView!
    
    var data1 = [DataSnapshot]()
    var data3 = [String]()
    
    @IBOutlet weak var topLabel: UILabel!
    
    var selectedChatType:Constants.ChatType = .Private
    var privateChatMemberEmail = ""
    var publicChannel = ""
    
    @IBAction func privateButton(_ sender: UIBarButtonItem) {
        sender.tintColor = UIColor.black
        publicBtn.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        table1.isHidden = false
        table3.isHidden = true
        
        topLabel.text = "1-to-1 Private Chat"
        selectedChatType =  .Private
    }
    
    
    @IBAction func publicButton(_ sender: UIBarButtonItem) {
        sender.tintColor = UIColor.black
        privateBtn.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        table1.isHidden = true
        table3.isHidden = false
        
        topLabel.text = "Public Channels"
        selectedChatType = .Public
    }
    
    func fillData1(){
        let ref = Database.database().reference()
        _ = ref.child("registeredUsers").observe(.childAdded) { (snapshot: DataSnapshot)in
            let text = snapshot.value as! [String:String]
             let mail = text["mail"]!
            let authMail = Auth.auth().currentUser?.email?.replacingOccurrences(of: ".", with: "_")
            if (mail != authMail){ //hide own email from chat members list
            self.data1.append(snapshot)
            self.table1.insertRows(at: [IndexPath(row: self.data1.count-1, section: 0)], with: .automatic)
            }
        }
    }
    
    func fillData3(){
        let ref = Database.database().reference()
        _ = ref.child("PublicChannels").observe(.childAdded) { (snapshot: DataSnapshot)in
            let text = snapshot.key
            self.data3.append(text)
            self.table3.insertRows(at: [IndexPath(row: self.data3.count-1, section: 0)], with: .automatic)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillData1()
        fillData3()
    }



     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == table1) {return data1.count}
        else{ return data3.count}
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        if tableView == table1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            var text = data1[indexPath.row].value as! [String:String]
            cell.textLabel?.text =  text["mail"]

        }
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath)
            cell.textLabel?.text = data3[indexPath.row]
        }
        cell.textLabel?.textAlignment = .center
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == table1 {
            let text = data1[indexPath.row].value as! [String:String]
            if let mail = text["mail"]{
                privateChatMemberEmail  = mail
                
            }
        }else{
            publicChannel  = data3[indexPath.row]
        }
        
        performSegue(withIdentifier: "ChatWindow", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatWindow"{
            if let dest =  segue.destination as? FCViewController{
                dest.chatType = selectedChatType
                dest.privateChateMemberEmail = privateChatMemberEmail
                dest.publicChannel = publicChannel
                if dest.chatType == .Private{
                    dest.toolbarTitleText =  privateChatMemberEmail.components(separatedBy: "@")[0]
                }
                else{
                    dest.toolbarTitleText = publicChannel + " [public]"
                }
            }
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
