//
//  ViewController.swift
//  GCDSample
//
//  Created by Viet Le on 01/09/2021.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchNames = names
    
    var pendingWorkitem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
        testDispatchWorkItem()
        config()
    }
    
    private func config() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.reloadData()
        
        searchBar.showsCancelButton = true
        searchBar.delegate = self
    }
    
    func search(text: String) {
        pendingWorkitem?.cancel()
        
        pendingWorkitem = DispatchWorkItem.init(block: {
            if text.isEmpty {
                self.searchNames = names
            } else {
                self.searchNames = names.filter({ name in
                    name.lowercased().contains(text.lowercased())
                })
            }
            self.tableView.reloadData()
            // thay đoạn này thành call API Search nếu trong dự án có dữ liệu ở server và cần search
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: pendingWorkitem!)
    }
    
    func testDispatchWorkItem() {
        let workItem_UpdateUI = DispatchWorkItem.init {
            self.view.backgroundColor = .red
            
            print("Finished workItem 1")
        }
        
        let workItem_2 = DispatchWorkItem.init {
            for i in 20..<25 {
                print(i)
            }
            
            print("Finish workItem 2")
        }
        
        // search
        workItem_2.notify(queue: .main) {
            workItem_UpdateUI.perform()
        }
        
        DispatchQueue.global().async(execute: workItem_2)
        workItem_UpdateUI.cancel()
    }
    
    
    
    func testDispatchGroup() {
        let group = DispatchGroup()
        
        let concurrent = DispatchQueue(label: "Concurrent",qos: .background, attributes: .concurrent)
        
        group.enter()
        concurrent.async {
            for i in 0..<10 {
                print(i)
            }
            print("Finished Task 1")
            group.leave()
        }
        
        group.enter()
        concurrent.async {
            for i in 10..<20 {
                print(i)
            }
            print("Finished Task 2")
            group.leave()
        }
        
        group.enter()
        concurrent.async {
            for i in 70..<80 {
                print(i)
            }
            print("Finished Task 3")
            group.leave()
        }
        
        group.notify(queue: .main) {
            print("All Task finished")
        }
    }
    
    func testDispatchSemaphore() {
        let concurrent = DispatchQueue(label: "Concurrent",qos: .background, attributes: .concurrent)
        let semaphore = DispatchSemaphore.init(value: 1)
        
        concurrent.async {
            print("Start Task 1")
            for i in 0..<10 {
                print(i)
            }
            print("Finished Task 1")
            semaphore.signal()
        }
        
        // concurrent Queue => Thêm tác vụ vào => Tạo Thêm Thread để xử lý tác vụ vừa thêm vào
        // Thêm nhiều tác vụ => Tạo ra thêm nhiều Thread
        // Nhiều Thread này chạy song song
        // CPU , Ram .....
        // Semaphore => Quản lý số Task được phép thu
        
        
        semaphore.wait() // semophore Count = 1 - 1  = 0
        concurrent.sync {
            print("Start Task 2")
            for i in 10..<20 {
                print(i)
            }
            print("Finished Task 2")
            semaphore.signal() // SemophoreCount + 1 = 0 =>> Dòng 43 không bị block nữa => được hoạt động bình thường
        }
        
        // 1 Thread => Xử lý một tác vụ
        
        semaphore.wait() // semaphore count = 0 - 1 = -1 < 0  .. Block Luồng hiện tại lại để chờ tín hiệu Signal
        concurrent.sync {
            print("Start Task 3")
            for i in 20..<30 {
                print(i)
            }
        }
    }

    @IBAction func photoButtonDidTap(_ sender: Any) {
        let controller = PhotoViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func pickPhototoButtonDIdTap(_ sender: Any) {
        let picker = UIImagePickerController.init()
        picker.sourceType = .photoLibrary
        
//        picker.sourceType = .camera
        
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func pickDateButtonDidTap(_ sender: Any) {
        let calendarController = CalendarViewController.init()
        calendarController.delegate = self
        calendarController.selectedDate = Date()
        calendarController.show(on: self)
    }
    
}

//MARK: - CalendarViewControllerDelegate
extension ViewController: CalendarViewControllerDelegate {
    func canSelectDate(_ date: Date) -> Bool {
        return true
    }
    
    func calendarViewController(_ controller: CalendarViewController, didSelectDate date: Date) {
        print("select date = \(date)")
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        print(image?.size)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = searchNames[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(text: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        search(text: "")
    }
}
