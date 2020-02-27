//
//  FavoritesViewController.swift
//  Exam-PG5600-Tabbed
//


import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var recommendedCollectionView: UICollectionView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var favoriteTracks: [NSManagedObject] = []
    var recArtists: [ArtistData] = []
    var query: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoritesTableView.dataSource = self
        favoritesTableView.delegate = self
        favoritesTableView.register(UINib(nibName: "FavoriteTableViewCell", bundle: nil), forCellReuseIdentifier: "favCell")

        
        recommendedCollectionView.dataSource = self
        recommendedCollectionView.delegate = self
        recommendedCollectionView.register(UINib(nibName: "RecommendedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "artistColCell")
    }
    
    //EDIT MODE
    @IBAction func editMode(_ sender: Any) {
        if favoritesTableView.isEditing == true {
            favoritesTableView.isEditing = false
        } else {
            favoritesTableView.isEditing = true
        }
    }
    
    //FETCH FAVORITE DATA
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Track")
        
        do {
            favoriteTracks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch data. \(error), \(error.userInfo)")
        }
        
        recArtists = []
        self.query = ""
        getQuery()
        if(self.query != ""){
            fetchArtists(query: self.query)
        }
        favoritesTableView.reloadData()
        recommendedCollectionView.reloadData()
    }
    
    //FETCH RECOMMENDED ARTISTS DATA
    func fetchArtists(query: String) {
        DispatchQueue.main.async {
            Alamofire.request("https://tastedive.com/api/similar?q=" + query + "&k=350803-iosexam-XCZD59Y1").responseJSON(completionHandler: {
                (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let data = json["Similar"]["Results"]
                    data.array?.forEach({ (artist) in
                        let artist = ArtistData(
                            name: artist["Name"].stringValue
                        )
                        self.recArtists.append(artist)
                    })
                self.recommendedCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    //RECOMMENDED QUERY
    func getQuery() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Track")
        
        let artists = try! managedContext.fetch(fetchRequest)
        var duplicates: [String] = []
        
        if(artists.count != 0){
            for n in 0...artists.count - 1 {
                let objectArtist = artists[n] as! NSManagedObject
                duplicates.append(objectArtist.value(forKey: "strArtist") as! String)
            }
            let unique = Array(Set(duplicates))
            
            var plussArray: [String] = []
            for item in unique {
                let replace = item.replacingOccurrences(of: " ", with: "+")
                plussArray.append(replace)
            }
            
            query = plussArray.joined(separator: "%2C+")
        } else {
            query = ""
        }
        
    }
    
    //DELETE DATA
    func delete(track: NSManagedObject) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(track)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save data. \(error), \(error.userInfo)")
        }
        
        recArtists = []
        self.query = ""
        getQuery()
        if(self.query != ""){
            fetchArtists(query: self.query)
        }
        recommendedCollectionView.reloadData()
    }

}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        favoritesTableView.deselectRow(at: indexPath, animated: true)
        
        let cell = favoritesTableView.dequeueReusableCell(withIdentifier: "favCell") as! FavoriteTableViewCell
        
        cell.favTrackLabel?.text = favoriteTracks[indexPath.row].value(forKeyPath: "strTrack") as? String
        cell.favArtistLabel?.text = favoriteTracks[indexPath.row].value(forKeyPath: "strArtist") as? String
        cell.favTimeLabel?.text = favoriteTracks[indexPath.row].value(forKeyPath: "intDuration") as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let popUp = UIAlertController(title: "Confirm", message: "Are you sure you want to delete?", preferredStyle: .alert)
            
            let delete = UIAlertAction(title: "Delete", style: .default, handler: { (action) -> Void in
                print("Ok button tapped")
                self.delete(track: self.favoriteTracks[indexPath.row])
                self.favoriteTracks.remove(at: indexPath.row)
                self.favoritesTableView.deleteRows(at: [indexPath], with: .automatic)
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel button tapped")
            }
            
            popUp.addAction(delete)
            popUp.addAction(cancel)
            
            self.present(popUp, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        
        return .none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let rowToMove = favoriteTracks[sourceIndexPath.row]
        
        favoriteTracks.remove(at: sourceIndexPath.row)
        favoriteTracks.insert(rowToMove, at: destinationIndexPath.row)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recArtists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = recommendedCollectionView.dequeueReusableCell(withReuseIdentifier: "artistColCell", for: indexPath) as! RecommendedCollectionViewCell
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        
        cell.recArtistLabel?.text = self.recArtists[indexPath.row].name
        
        return cell
    }
}

