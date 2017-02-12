//
//  ClientProfileController.swift
//  BookKeeper
//
//  Created by Shu-Mei Cheng on 1/30/17.
//  Copyright © 2017 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ClientProfileController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate{
    
    var client: Client?
    var products: List<Product>?
    var thisField: UITextField?
    
    var realm: Realm?
    let tableSection = ["Products","Special Notes","Total Revenue"]
    
    @IBOutlet weak var clientTiltle: UINavigationItem!

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        try! realm = Realm()
        clientTiltle.title = (client?.firstName)! + " " + (client?.lastName)!
        products = client?.products
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSection[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // client name
        // products
        // special notes
        if( section == 0 ){
            if ((products?.count)! > 0 ){
                return (products?.count)!
            }else {
                return 1
            }
        }else {
            return 1
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("begin editing")
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        textField.inputView = datePickerView
        thisField = textField
        datePickerView.addTarget(self, action: #selector(self.handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
    }
    
    
    func handleDatePicker(sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateString = dateFormatter.string(from: sender.date)
        print(dateString)
        thisField?.text = dateString // HAVE TO USE THIS VARIABLE TO DISPLAY ON THE TEXTFIELD
    }
    
    func pickerDone (){
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        if(indexPath.section == 2 ){
            // revenue report by range
           
            var startDate: String?
            var endDate: String?
            
            let alert = UIAlertController(title: "Revenue report", message: "Choose the start and end dates", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?[0].delegate = self
            alert.textFields?[1].delegate = self
            alert.textFields?[0].placeholder = "start date"
            alert.textFields?[1].placeholder = "end date"
            
            let ok = UIAlertAction(title: "Ok", style: .default, handler: {
                (action) in
                // save the start and end date.
                startDate = alert.textFields?[0].text
                endDate = alert.textFields?[1].text
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(ok)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
   
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        if(indexPath.section == 0 ){ // product sections
            var product: Product?
            
            if ((products?.count)! > indexPath.row){
                product = products?[indexPath.row]
            }else {
                return cell
            }
            
            let name = product?.name

            let cost = String(describing: product!.cost)
            var date: Date?
            if((client?.dates.count)! > indexPath.row){
                date = client?.dates[indexPath.row].date as Date?
            }else{
                date = Date()
            }
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .medium
            let dateString = formatter.string(from:date!)
            
            cell.textLabel?.text = name!
            cell.detailTextLabel?.text = "$" + cost + " " + dateString
        }
        if(indexPath.section == 1){
            cell.textLabel?.numberOfLines = 0
            
            cell.textLabel?.text = client?.specialNotes
            cell.detailTextLabel?.text = " "
        }else {
            var total:Float = 0.0
            if(products?.count == 0 ){
                cell.textLabel?.text = String(total)
                return cell
            }
            for product in products! {
                total = product.cost + total
            }
            cell.textLabel?.text = String(total)
        }
        
        return cell
    }
    
    @IBAction func pressAdd(_ sender: Any) {
        let alert = UIAlertController(title: "Add product or notes", message: "Add a product or notes?", preferredStyle: .alert)
        let productAction = UIAlertAction(title: "Add a product", style: .default, handler: {
            (action) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductController") as! ProductController
            vc.client = self.client
            vc.clientTableView = self.tableView
            let products = self.realm?.objects(Product.self)
            vc.products = products
            self.present(vc, animated: true, completion: nil)
       
        })
        
        alert.addAction(productAction)
        let noteAction = UIAlertAction(title: "Add a new note", style: .default, handler: {
            (action) in
            let alertNote = UIAlertController(title: "Special Notes", message: "Please enter a special note.", preferredStyle: .alert)
            alertNote.addTextField(configurationHandler: nil)
            alertNote.textFields?[0].placeholder = "Enter a new note here."
            let ok = UIAlertAction(title: "Done", style: .default, handler: {
                (action) in
                let note = alertNote.textFields?[0].text
                try! self.realm?.write {
                    self.client?.specialNotes = (self.client?.specialNotes)! + ", " + note!
                }
                self.tableView.reloadData()
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertNote.addAction(cancel)
            alertNote.addAction(ok)
            
            self.present(alertNote, animated: true, completion: nil)
            
        })
        alert.addAction(noteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    
    }
    
    @IBAction func pressDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
