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
import MessageUI


class BalanceSheetController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var realm: Realm?
    var totalIncome: Float?
    var totalExpense: Float?
    var startDate: Date?
    var endDate: Date?
    var products: [Product]? // Income
    var expenses: [Expense]?
    var myClients: [Client]? // Date for each Income
    var indexToProducts: [Int]? // for each client index to dates and products
    
    let sections = ["Income","Expenses","Revenue"]
    
    @IBOutlet weak var tableView: UITableView!
    
    func reloadExpenses(){
        expenses = [Expense]()

        if((((startDate) != nil) && ((endDate) != nil) && startDate! < endDate!) || startDate == nil ){
            
            let exps = realm?.objects(Expense.self)
            for exp in exps!{
                if(startDate != nil){
                    if(startDate! <  exp.date! || startDate! == exp.date!){
                        if(endDate! > exp.date! || endDate! == exp.date!){
                            expenses?.append(exp)
                        }
                        
                    }
                    
                }else{
                    expenses?.append(exp)
                }
            }
        }
        
    }
    
    func reloadIncome()
    {
        products = [Product]()
        myClients = [Client]()
        indexToProducts = [Int]()
        
        if((((startDate) != nil) && ((endDate) != nil) && startDate! < endDate!) || startDate == nil ){
            // filter
            let clients = realm?.objects(Client.self)
            for client in clients! {
                var count = 0
                for prod in client.products{
                    if(startDate != nil){
                        if(client.dates[count].date! > startDate! || client.dates[count].date! == startDate!){
                            if(client.dates[count].date! < endDate! || client.dates[count].date! == endDate!){
                                products?.append(prod)
                                myClients?.append(client)
                                indexToProducts?.append(count)
                            }
                        }
                    }else{
                        myClients?.append(client)
                        products?.append(prod)
                        indexToProducts?.append(count)
                    }
                    count = count + 1
                }//for prod
                
            }// for client
        }
        
    }
    
    override func viewDidLoad() {
       try! realm = Realm()
        totalIncome = 0.0
        totalExpense = 0.0
        reloadIncome()
        reloadExpenses()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0 ) { // income from every clients services
            let count = products?.count
            return count!
            
        }else if(section == 1){ // expenses
            
            return (expenses?.count)!
        }else {
            return 1
        }
    }
    
    func getADateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let dateString = formatter.string(from:date)

        return dateString
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceSheetTableViewCell", for: indexPath) as! BalanceSheetTableViewCell
        if(indexPath.section == 0 ){
            
            if(myClients?.count == 0){
                cell.textLabel?.text = " "
                cell.detailTextLabel?.text = " "
                return cell
            }
           
            let client =  myClients?[indexPath.row]
            if (client == nil || products?.count == 0 ){
                cell.textLabel?.text = " "
                cell.detailTextLabel?.text = " "
                return cell
            }
            var product: Product!
            product = products?[indexPath.row]
            let index = indexToProducts?[indexPath.row]
            let date = client?.dates[index!].date
            let dateString = getADateString(date: date!)
            let name = (client?.firstName)! + " " + (client?.lastName)!
            cell.textLabel?.text = name +  " " + (product?.name)! + " " + dateString
            var cost: String!
            cost = String(describing: product.cost)
            cell.detailTextLabel?.text = "$" + cost
            totalIncome = totalIncome! + (product?.cost)!
        }else if (indexPath.section == 1){
           
            if(expenses?.count == 0 ){
                cell.textLabel?.text = " "
                cell.detailTextLabel?.text = " "
                return cell
            }
            var expense: Expense!
            expense = expenses?[indexPath.row]
            let date = expense.date
            let dateString = getADateString(date: date!)

            cell.textLabel?.text = (expense?.name)! + " " + dateString
            var cost: String!
            cost = String(describing: expense.cost)

            cell.detailTextLabel?.text = "$" + cost
            totalExpense = totalExpense! + (expense?.cost)!
        }else if (indexPath.section == 2) { // total revenue
            totalIncome = 0
            for product in products!{
                totalIncome = totalIncome! + product.cost
            }         
            totalExpense = 0.0
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            // delete Income or expenses
            if(indexPath.section == 0 ){
                // delete Income
                let index = indexToProducts?[indexPath.row]
               
                let client = myClients?[indexPath.row]
                try! realm?.write(){
                    client?.dates.remove(objectAtIndex: index!)
                    client?.products.remove(objectAtIndex: index!)
                }
                reloadIncome()
            }else if (indexPath.section == 1 ){
                let exp = expenses?[indexPath.row]
                try! realm?.write {
                    realm?.delete(exp!)
                }
                reloadExpenses()
            }
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "datePickerSegue"){
            let vc = segue.destination as! DatePickerController
            vc.parentView = self
        }
        
    }
    
    func writeBalance() -> String {
        //
        var content: String?
        content = "Income\n"
        content = content! + "======================\n"
                var count = 0
        var totalIncome = Float(0.0)
        for prod in products! {
            let index = indexToProducts?[count]
            let name = (myClients?[count].firstName)! + (myClients?[count].lastName)!
            let date = myClients?[count].dates[index!]
            let dateString = getADateString(date: (date?.date!)!)
            
            content = content! + name + " " + prod.name + " $"
            content = content! + String(prod.cost) + "\n" + dateString + "\n"
            
            count = count + 1
            totalIncome = totalIncome + prod.cost
        }
        content = content! + "======================\n"
        content = content! + "Total Income is " + String(totalIncome) +  "\n"
        content = content! + "======================\n"
        content = content! +  "Expenses\n"
        content = content! + "======================\n"
        var totalExp = Float(0.0)
        for exp in expenses!{
            let cost = String(exp.cost)
            let costStr = exp.name + " $" + cost + "\n" + getADateString(date: exp.date!) + "\n"
            content = content! +  costStr
            totalExp = totalExp + exp.cost
        }
        content = content! + "======================\n"
        content = content! + "Total Expenses is " + "$" + String(totalExp) + "\n"
        content = content! + "======================\n"
        content = content! + "Total Revenue is " + String(totalIncome - totalExp) + "\n"
        return content!
    }
    
    func writeDataToFile(file:String)-> URL{
       
        var path: URL?
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            path = dir.appendingPathComponent(file)
            if(FileManager.default.fileExists(atPath: (path?.path)!)){
                try! FileManager.default.removeItem(atPath: (path?.path)!)
                
            }
            let content = writeBalance()
         
            FileManager.default.createFile(atPath: (path?.path)!, contents: content.data(using: .utf8, allowLossyConversion: false))
            
        }
        return path!
    }
    

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @IBAction func pressExport(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("BalanceSheet")
           
            let filename = "myFile.txt"
            
            let url = writeDataToFile(file: filename)
            // Use NSData to get data otherwise it wont work!!
            let data = NSData(contentsOf: url)
           
            mail.addAttachmentData(data! as Data , mimeType: "text/txt", fileName: url.absoluteString)
            mail.setMessageBody("<p>Here is your balance sheet in the attachment!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            let alert = UIAlertController(title: "can not send email!", message: "failed to send email", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: {
                (action) in
                    self.dismiss(animated: true, completion: nil)
                
            })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // add take a picture action
    func takeAPhoto(alert: UIAlertController){
        let takePhoto = UIAlertAction(title: "Take a Photo", style: .default, handler: {(action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        alert.addAction(takePhoto)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
           // imageView.contentMode = .ScaleAspectFit
            //imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // select a photo
    func selectAPhoto( alert: UIAlertController){
        let selectPhoto = UIAlertAction(title: "Select a Photo", style: .default, handler: {(action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        alert.addAction(selectPhoto)
    }
    
    @IBAction func addExpenses(_ sender: Any) {
        let alert = UIAlertController(title: "Expenses", message: "Add Expenses?", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].placeholder = "name of expense."
        alert.textFields?[1].placeholder = "how much?"
        let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            let name = alert.textFields?[0].text
            var cost: String!
            
            cost = ((alert.textFields?[1].text)!)
            if(cost == nil){
                return
            }
            let date = Date()
            try! self.realm?.write {
                let  expense = Expense()
                expense.name = name!
                expense.cost = Float(cost)!
                expense.date = date
                self.realm?.add(expense)
            }
            self.reloadExpenses()
            self.tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(ok)
        takeAPhoto(alert: alert)
        selectAPhoto(alert: alert)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pressDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
