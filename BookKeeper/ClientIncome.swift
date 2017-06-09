//
//  ClientIncome.swift
//  BookKeeper
//
//  Created by Shu-Mei Cheng on 2/12/17.
//  Copyright © 2017 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
class ClientIncome: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var client: Client?
    var products:[Product]?
    var dates: [serviceDate]?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clientName: UINavigationItem!
    
     override func viewDidLoad() {
        clientName.title = (client?.firstName)! + " " + (client?.lastName)!
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ClientIncomeTableViewCell", for: indexPath) as! ClientIncomeTableViewCell
        cell.textLabel?.numberOfLines =  0
      
       
        
        let product = products?[indexPath.row]
        let date = dates?[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let dateString = formatter.string(from:(date?.date!)!)
        let cost: Float = (product?.cost)!
        let costString = String(describing: cost)
        var title = (product?.name)!
        cell.textLabel?.text = title + " " + dateString
        cell.detailTextLabel?.text = costString
        return cell
    }
    
    @IBAction func pressDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
