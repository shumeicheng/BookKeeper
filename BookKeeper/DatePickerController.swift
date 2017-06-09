//
//  DatePickerController.swift
//  BookKeeper
//
//  Created by Shu-Mei Cheng on 2/18/17.
//  Copyright © 2017 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class DatePickerController: UIViewController{
    var realm: Realm?
    @IBOutlet weak var thisTitle: UINavigationItem!
    @IBOutlet weak var startDate: UITextField!
    var textField: UITextField?
    var parentView: UIViewController?
    
    
    @IBOutlet weak var endDate: UITextField!
     @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        try! realm = Realm()
    }
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
        let datePicker = sender as! UIDatePicker
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        let date = datePicker.date
        
        let dateString = dateFormatter.string(from: date)
        textField?.text = dateString
    }
    
    @IBAction func startDateTouchDown(_ sender: Any) {
        textField = startDate
    }
    
    @IBAction func endDateTouchDown(_ sender: Any) {
        textField = endDate
    }
    
    @IBAction func pressDone(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BalanceSheetController") as! BalanceSheetController
        //convert String back to Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        let sDate = dateFormatter.date(from: startDate.text!)
        let eDate = dateFormatter.date(from: endDate.text!)
        vc.startDate = sDate
        vc.endDate = eDate
        dismiss(animated: true, completion: nil)
        parentView?.present(vc, animated: true, completion: nil)
        
    }
}
