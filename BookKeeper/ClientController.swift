//
//  ClientController.swift
//  BookKeeper
//
//  Created by Shu-Mei Cheng on 1/28/17.
//  Copyright © 2017 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ClientController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var realm: Realm?
    var clients: Results<Client>?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        realm = try! Realm()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return (clients?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientTableViewCell", for: indexPath) as! ClientTableViewCell
        if((clients?.count)! > 0 ){
            let client = clients?[indexPath.row]
            cell.textLabel?.text = (client?.firstName)! + " " + (client?.lastName)!
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if(indexPath.row < (clients?.count)!) {
                let client = clients?[indexPath.row]
                try! realm!.write {
                    realm!.delete(client!)
                }
                clients = realm?.objects(Client.self)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                tableView.reloadData()
                
                
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ClientTableViewCell", for: indexPath) as! ClientTableViewCell
        
        let client = clients?[indexPath.row]
        // add product or get report, edit client profile
        let alert = UIAlertController(title: "Client Profile", message: "Open client profile?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            // go to client profile controller
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ClientProfileController") as! ClientProfileController
            vc.client = client
            self.present(vc, animated: true, completion: nil)
             tableView.reloadData()
        })
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
        (action) in
            alert.dismiss(animated: true, completion: nil)
            tableView.reloadData()
        })
        alert.addAction((cancelAction))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pressAdd(_ sender: Any) {
        let alert = UIAlertController(title: "Enter Client", message: "Please enter clients name and special notes", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addTextField(configurationHandler: nil)
        alert.addTextField(configurationHandler: nil)
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].placeholder = "FirstName"
        alert.textFields?[1].placeholder = "LastName"
        alert.textFields?[2].placeholder = "special notes"
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            (action) in
            // save client in Realm
            let client = Client()
            client.firstName = (alert.textFields?[0].text)!
            client.lastName = (alert.textFields?[1].text)!
            client.specialNotes = (alert.textFields?[2].text)!
            try! self.realm?.write {
                self.realm?.add(client)
            }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .default, handler:{ (action) in
            self.dismiss(animated: true, completion: nil)
            
        }
        ))

        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pressDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
