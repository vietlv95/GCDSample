//
//  PhotoViewController.swift
//  GCDSample
//
//  Created by Viet Le on 01/09/2021.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var reviewTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var houseImageView: UIImageView!
    
    let carURL = URL(string: "https://i.pinimg.com/originals/11/fb/9f/11fb9f12acfc005e28053b906b51d8a5.jpg")!
    let houseURL = URL(string: "https://img.thuthuatphanmem.vn/uploads/2018/10/19/3d-wallpaper-4k-full-hd_040150427.jpg")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewTextField.isHidden = true
        submitButton.isHidden = true
        
        titleLabel.text = "Photos"
        carImageView.layer.cornerRadius = 10
        houseImageView.layer.cornerRadius = 10
        downloadPhoto()
        
    }

    func downloadPhoto() {
        let loadCarPhotoWorkItem = DispatchWorkItem.init {
            if let carData = try? Data.init(contentsOf: self.carURL) {
                let carImage = UIImage.init(data: carData)
                DispatchQueue.main.async {
                    self.carImageView.image = carImage
                }
            }
        }
        
        let loadHousePhotoWorkItem = DispatchWorkItem.init {
            if let houseData = try? Data.init(contentsOf: self.houseURL) {
                let houseImage = UIImage.init(data: houseData)
                DispatchQueue.main.async {
                    self.houseImageView.image = houseImage
                }
            }
        }
        
        let group = DispatchGroup()
        
        group.enter()
        
        DispatchQueue.global().async {
            loadCarPhotoWorkItem.perform()
            group.leave()
        }
        
        group.enter()
        DispatchQueue.global().async {
            loadHousePhotoWorkItem.perform()
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.reviewTextField.isHidden = false
            self.submitButton.isHidden = false
        }
    }

    @IBAction func backButtonDidTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
