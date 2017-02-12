//
//  Start.swift
//  BookKeeper
//
//  Created by Shu-Mei Cheng on 1/28/17.
//  Copyright © 2017 Shu-Mei Cheng. All rights reserved.
//

import UIKit
import RealmSwift

class StartController: UIViewController {
    @IBOutlet weak var productsButton: UIButton!
    @IBOutlet weak var balanceSheetButton: UIButton!
    @IBOutlet weak var clientsButton: UIButton!
    var realm: Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //try! FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        realm = try! Realm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressProducts(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProductController") as! ProductController
        let products = realm?.objects(Product.self)
        vc.products = products
      
        present(vc, animated: true, completion: nil)
    }

    @IBAction func pressClients(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ClientController") as! ClientController
        let clients = realm?.objects(Client.self)
        vc.clients = clients
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func pressBalanceSheet(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BalanceSheetController") as! BalanceSheetController
        present(vc, animated: true, completion: nil)
    }
}

