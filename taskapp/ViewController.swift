//
//  ViewController.swift
//  taskapp
//
//  Created by 鈴木光基 on 2023/06/19.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController:                                         UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date",ascending: true )
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      searchBar.placeholder = "検索したい文字列を入力してください"
        
        
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        updateTaskArray()
    }
    
    func updateTaskArray(with searchText: String = "") {
          if searchText.isEmpty {
              taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
          } else {
              taskArray = realm.objects(Task.self).filter("title CONTAINS[c] %@", searchText).sorted(byKeyPath: "date", ascending: true)
          }
          
          tableView.reloadData()
      }
      
      // UISearchBarDelegate method
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          updateTaskArray(with: searchText)
      }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "Cell", for : indexPath)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return . delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id.stringValue)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            inputViewController.task = Task()
        }
    }
    
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    }
