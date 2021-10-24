//
//  DetailsViewController.swift
//  ArtBookwithCoreData
//
//  Created by Bukefalos on 23.10.2021.
//

import UIKit
import CoreData
class DetailsViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        
        if chosenPainting != ""{
            //saveButton.isEnabled = false
            saveButton.isHidden = true
            
            // Core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let idString = chosenPaintingId?.uuidString
            
            let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchReq.returnsObjectsAsFaults = false
            fetchReq.predicate = NSPredicate(format: "id = %@",  idString!)
            do{
                let results = try context.fetch(fetchReq)
                if results.count > 0{
                    
                    
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch{
                print("error")
            }
            
            
        }
       
        // Klavyeyi kapatma
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        newPainting.setValue(nameText.text, forKey: "name")
        newPainting.setValue(artistText.text, forKey: "artist")
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
            
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        do {
            try context.save()
            print("success")
        }
            catch{
                print("error")
            }
        
        
        // Notification Center Kullanımı
        NotificationCenter.default.post(name: NSNotification.Name("New Data"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        // TODO Click Save Button
    }
    
    
    
    
    
    
    // Resim Seçme
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    // Resim Seçme Bittiğinde Burası Çalışır
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Hangi resmin alınması gerektiğini seçen fonk
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        saveButton.isEnabled = true
    }
    
    
    
    
    
    
    
    
    
    
    // Klavye Gizleme
    @objc func hideKeyboard(){
        view.endEditing(true)
        
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
