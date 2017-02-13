//
//  BalanceSheetController.swift
//  BookKeeper
//
//  Created by Shu-Mei Cheng on 1/28/17.
//  Copyright © 2017 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class BalanceSheetController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var realm: Realm?
    var totalIncome: Float?
    var totalExpense: Float?
    
    let sections = ["Income","Expenses","(click below to add expenses.)","Revenue"]
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
       try! realm = Realm()
        totalIncome = 0.0
        totalExpense = 0.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 1){
            return 0
        }else if(section == 0 ) { // income from every clients services
            let clients = realm?.objects(Client.self)
            if(clients?.count == 0){
              return 0
            }
            var count = 0
            for client in (clients)! {
                let products = client.products
                count = count + products.count
            }
            return count + 1
            
        }else if(section == 2){ // expenses
            let expenses = realm?.objects((Expense.self))
            if(expenses?.count == 0){
                return 1
            }
            return ((expenses?.count)!+1)
        }
        return 1
    }
    
    func findClient(clients:Results<Client>, index: Int, total:inout Int ) -> Client? {
        total = 0
        var foundClient: Client?
        for client in clients {
            total = total + client.products.count
            if (total  > index){
                foundClient = client
                break
            }
        }
        return foundClient
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceSheetTableViewCell", for: indexPath) as! BalanceSheetTableViewCell
        if(indexPath.section == 0 ){
            let clients = realm?.objects(Client.self)
            if(clients?.count == 0){
                cell.textLabel?.text = " "
                cell.detailTextLabel?.text = " "
                return cell
            }
            var total = 0
            let client = findClient(clients: clients!, index: indexPath.row, total:&total)
            let remainder = total - indexPath.row
            let products = client?.products
            if (client == nil || products?.count == 0 ){
                cell.textLabel?.text = " "
                cell.detailTextLabel?.text = " "
                return cell
            }
            var product: Product!
            product = products?[remainder-1]
            let name = (client?.firstName)! + " " + (client?.lastName)!
            cell.textLabel?.text = name +  " " + (product?.name)!
            var cost: String!
            cost = String(describing: product.cost)
        
            cell.detailTextLabel?.text = "$" + cost
            totalIncome = totalIncome! + (product?.cost)!
        }else if (indexPath.section == 2){
            let expenses = realm?.objects(Expense.self)
            if(expenses?.count == 0 || expenses?.count == indexPath.row ){
                cell.textLabel?.text = " "
                cell.detailTextLabel?.text = " "
                return cell
            }
            var expense: Expense!
            expense = expenses?[indexPath.row]
            cell.textLabel?.text = expense?.name
            var cost: String!
            cost = String(describing: expense.cost)

            cell.detailTextLabel?.text = "$" + cost
            totalExpense = totalExpense! + (expense?.cost)!
        }else if (indexPath.section == 3) { // total revenue
            totalIncome = 0
            let clients = realm?.objects(Client.self)
            for client in clients! {
                let products = client.products
                for product in products{
                    totalIncome = totalIncome! + product.cost
                }
            }
            totalExpense = 0.0
            let expenses = realm?.objects(Expense.self)
            if(expenses?.count == 0){
                totalExpense = 0.0
            }else {
                for expense in expenses! {
                    totalExpense = totalExpense! + expense.cost
                }
            }
            let total = totalIncome! - totalExpense!
            let str = "$" + String(total)
            cell.textLabel?.text = str
            if(total > 0 ){
                cell.detailTextLabel?.text = "Good Job!"
            }else {
                cell.detailTextLabel?.text = "Keep going!"
            }
        }
        
        return cell
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 2){// expense row to add expenses
            let alert = UIAlertController(title: "Expenses", message: "Add Expenses?", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?[0].placeholder = "name of expense."
            alert.textFields?[1].placeholder = "how much?"
            let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                let name = alert.textFields?[0].text
                var cost: String!
                cost = ((alert.textFields?[1].text)!)
                let date = Date()
                try! self.realm?.write {
                    let  expense = Expense()
                    expense.name = name!
                    expense.cost = Float(cost)!
                    expense.date = date
                    self.realm?.add(expense)
                }
                tableView.reloadData()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(ok)

            present(alert, animated: true, completion: nil)
        }
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    @IBAction func pressReport(_ sender: Any) {
    }
    @IBAction func pressDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
