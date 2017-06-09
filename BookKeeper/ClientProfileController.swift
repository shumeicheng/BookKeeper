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
        alertCheckAdd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alertCheckAdd()
    }

    func alertAdd(title: String, message: String) -> Void{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: {
          (action) in
          
        }
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func alertCheckAdd(){
        let noProduct = client?.products.count == 0
        let noNotes = client?.specialNotes == ""
        if(noProduct && noNotes == false){
            alertAdd(title: "No Product yet!", message: "You can click Add button to add.")
        }else if(noProduct == false && noNotes){
            alertAdd(title: "No Special Notes yet!", message: "You can click Add button to add.")
        }else if(noProduct && noNotes){
            let alertNote = alertAdd(title: "No Special Notes or Product yet!", message: "You can click Add button to add. Thanks!")
            alertAdd(title: "No Product yet!", message: "Click Add button to add.")
        }
        
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
            return (products?.count)!
            
        }else if(section == 1 ){
            if(client?.specialNotes == ""){
                return 0
            }else {
                return  1//specital notes
            }
        }else {
            return 1
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        textField.inputView = datePickerView
        thisField = textField
        datePickerView.addTarget(self, action: #selector(self.handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
    }
    
    
    func handleDatePicker(sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        let dateString = dateFormatter.string(from: sender.date)
        
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
            let currentDate = Date()
            alert.textFields?[0].placeholder = "please click here for start date"
            alert.textFields?[1].placeholder = "please click here for end date"
            
            let ok = UIAlertAction(title: "Ok", style: .default, handler: {
                (action) in
                // save the start and end date.
                var startD = Date()
                var endD = Date()
                let formatter =  DateFormatter()
                startDate = alert.textFields?[0].text
                endDate = alert.textFields?[1].text
                if(startDate == "" ){
                    self.alertAdd(title: "Empty Start Date", message: "Please enter start date!")
                    return
                }
                if(endDate == ""){
                    self.alertAdd(title: "Empty End Date", message: "Please enter end date!")
                }
                formatter.dateFormat = "MMM dd yyyy"

                startD = formatter.date(from: (startDate)!)!
                endD = formatter.date(from: (endDate)!)!
                
                
                alert.dismiss(animated: true, completion: nil)
                var setOfProducts = [Product]()
                var setOfDates = [serviceDate]()
                if(endD > startD){
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ClientIncome") as! ClientIncome
                    
                    vc.client = self.client
                    // create a list of products within the star and end dates
                    var count = 0
                    for prod in (self.client?.products)!{
                        let thisDate = self.client?.dates[count]
                        if((thisDate?.date!)! < endD || (thisDate?.date)! == endD){
                            if((thisDate?.date!)! > startD || thisDate?.date == startD){
                                  setOfProducts.append((prod))
                                  setOfDates.append((self.client?.dates[count])!)
                            }
                        }
                     
                        count = count + 1
                    }//for prod
                    if( setOfProducts.count == 0){
                        self.alertAdd(title: "No product found", message: "During searching period.")
                        return
                    }
                    vc.products = setOfProducts
                    vc.dates = setOfDates
                    self.present(vc, animated: true, completion: nil)
                }
            })
            alert.addAction(ok)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
   
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == UITableViewCellEditingStyle.delete {
            if(indexPath.section == 0 ){
                var product: Product?
                var date: serviceDate?
                if(((products?.count)! > indexPath.row)){
                   // product = products?[indexPath.row]
                    date = client?.dates[indexPath.row]
                    try! realm?.write{
                       // realm?.delete(product!)
                        products?.remove(objectAtIndex: indexPath.row)

                        realm?.delete((date)!)
                    }
                }
                //update products
                products = client?.products
            } else if (indexPath.section == 1 ){
                try! realm?.write {
                    client?.setValue("", forKey: "specialNotes")
                    
                }
            }
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()

        }
 
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
        }else if(indexPath.section == 1){
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
                    if(self.client?.specialNotes == ""){
                        self.client?.specialNotes = note!
                    }else{
                        self.client?.specialNotes = (self.client?.specialNotes)! + ", " + note!
                    }
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
