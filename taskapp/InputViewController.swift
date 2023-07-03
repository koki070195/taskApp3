//
//  InputViewController.swift
//  taskapp
//
//  Created by 鈴木光基 on 2023/06/19.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
   
    let realm = try! Realm()
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date =  task.date
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write{
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
        }
        
        setNotfication(task: task)
        super.viewWillDisappear(animated)
    }
    
    func setNotfication(task: Task){
        let content = UNMutableNotificationContent()
        
        
        if task.title ==  "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == ""{
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
    
    
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
    let triggar = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    let request = UNNotificationRequest(identifier: String(task.id.stringValue), content: content, trigger: triggar)
    
    let center = UNUserNotificationCenter.current()
    center.add(request){ (error) in
        print(error ?? "ローカル通知　OK")
        
    }
    center.getPendingNotificationRequests { (requests: [UNNotificationRequest])in
        for request in requests {
            print("/------------")
            print(request)
            print("/------------")
        }
    }
}
    
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
