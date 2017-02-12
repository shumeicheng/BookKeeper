//
//  ProductController.swift
//  BookKeeper
//
//  Created by Shu-Mei Cheng on 1/28/17.
//  Copyright © 2017 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ProductController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var realm: Realm?
    var products: Results<Product>?
    var client: Client?
    var clientTableView: UITableView?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        realm = try! Realm()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        clientTableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(products?.count == 0){
            return 10
        }else {
            return products!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        if(indexPath.row < (products?.count)!){
            let product = products?[indexPath.row]
            let costString = String(product!.cost)
            cell.productCost.text = "$" + costString
            cell.productName.text = product!.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if(indexPath.row < (products?.count)!) {
                let product = products?[indexPath.row]
                try! realm!.write {
                    realm!.delete(product!)
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(products?.count == 0 ){
            let alert = UIAlertController(title: "Please add product first", message: "Click Add button to add a product.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: {
                (action) in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        }
        let alert = UIAlertController(title: "Production selection confirmation", message: "Choose this product?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            (action) in
            let product = self.products?[indexPath.row]
            try! self.realm?.write(){
                self.client?.products.append((product)!)
                let date = serviceDate()
                self.client?.dates.append(date)
            }
            tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }

    @IBAction func pressDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressAdd(_ sender: Any) {
        let alert = UIAlertController(title: "Enter Product", message: "Please enter product name and cost of the product", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].placeholder = "product name"
        alert.textFields?[1].placeholder = "product cost"
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            (action) in
            // save product in Realm
            let product = Product()
            product.name = (alert.textFields?[0].text)!
            product.cost = Float((alert.textFields?[1].text)!)!
            
            try! self.realm?.write {
                self.realm?.add(product)
            }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{ (action) in
            alert.dismiss(animated: true, completion: nil)
            
        }
        ))
        

        present(alert, animated: true, completion: nil)

    }
}
