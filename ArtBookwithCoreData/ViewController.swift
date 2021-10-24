//
//  ViewController.swift
//  ArtBookwithCoreData
//
//  Created by Bukefalos on 23.10.2021.
//

import UIKit
import CoreData
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        tableView.delegate = self
        tableView.dataSource = self
        // Nav Toolbara + butonu ekleme
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonclicked))
        getCoreData()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //  NotificationCenter ile gelen paketi dinleme ve aksiyon alma
        NotificationCenter.default.addObserver(self, selector: #selector(getCoreData), name: NSNotification.Name("New Data"), object: nil)
    }
    
    @objc func addButtonclicked(){
        
        selectedPainting = ""
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TableView Hücrelerinin İçeriğini Belirleme
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Tableview Hücre Sayısı
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Seçim Algılama
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Seçim Yapıldıysa Diğer Ekranı Haberdar Etmek
        if segue.identifier == "toDetailsVC" {
            
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintingId
            
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // Core Data ve TableView üzerinden silme işleminin yapılması
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = idArray[indexPath.row].uuidString
            fetchrequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchrequest.returnsObjectsAsFaults = false
            do{
            let results = try context.fetch(fetchrequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID  {
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do
                                {
                                 try context.save()
                                }
                                catch
                                {
                                print("error")
                                }
                                break
                        }
                        }
                    }
                }
            }
            catch{
                print("error")
            }
             
            
        }
    }
    // VERi ÇEKME COREDATA "
    
    @objc func getCoreData(){
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchReq.returnsObjectsAsFaults = false
        
        
        
        
        
        do {
            let results = try context.fetch(fetchReq)
            for result in results as! [NSManagedObject] {
                if let name =  result.value(forKey: "name") as? String{
                    nameArray.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID{
                    self.idArray.append(id)
                    
                }
                self.tableView.reloadData()
            }
            
        }
        catch{
            print("error")
        }
        
        
    }
    
    

}

