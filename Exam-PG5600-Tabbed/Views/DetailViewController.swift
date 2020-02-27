//
//  DetailViewController.swift
//  Exam-PG5600-Tabbed
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage
import SwiftyJSON

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailAlbumLabel: UILabel!
    @IBOutlet weak var detailArtistLabel: UILabel!
    @IBOutlet weak var detailYearLabel: UILabel!
    @IBOutlet weak var tracksTableView: UITableView!
    
    var passedDetails: AlbumData!
    var albumTracks: [AlbumTracksData] = []
    var favoriteTracks: [NSManagedObject] = []
    var downloadURL = NSURL()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tracksTableView.dataSource = self
        tracksTableView.delegate = self
        tracksTableView.register(UINib(nibName: "TracksTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        
        downloadURL = NSURL(string: passedDetails.strAlbumThumb)!
        detailAlbumLabel?.text = passedDetails.strAlbum
        detailArtistLabel?.text = passedDetails.strArtist
        detailYearLabel?.text = passedDetails.intYearReleased
        detailImageView.af_setImage(withURL: downloadURL as URL)
        
        fetchTracks()
    }
    
    //PARSING
    func fetchTracks() {
        DispatchQueue.main.async {
            Alamofire.request("https://theaudiodb.com/api/v1/json/1/track.php?m=\(self.passedDetails.idAlbum)").responseJSON(completionHandler: {
                (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let data = json["track"]
                    data.array?.forEach({ (track) in
                        let track = AlbumTracksData(
                            strTrack: track["strTrack"].stringValue,
                            intDuration: track["intDuration"].stringValue
                        )
                        self.albumTracks.append(track)
                    })
                    self.tracksTableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    //SAVE DATA
    func save(strTrack: String, strArtist: String, intDuration: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Track", in: managedContext)!
        let track = NSManagedObject(entity: entity, insertInto: managedContext)
        
        track.setValue(strTrack, forKeyPath: "strTrack")
        track.setValue(strArtist, forKeyPath: "strArtist")
        track.setValue(intDuration, forKeyPath: "intDuration")
        
        do {
            try managedContext.save()
            favoriteTracks.append(track)
        } catch let error as NSError {
            print("Could not save data. \(error), \(error.userInfo)")
        }
    }
    
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albumTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tracksTableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tracksTableView.dequeueReusableCell(withIdentifier: "trackCell") as! TracksTableViewCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.green
        cell.selectedBackgroundView = backgroundView
        
        let time: Int = Int(self.albumTracks[indexPath.row].intDuration)!
        let formatter = DateComponentsFormatter();
        formatter.allowedUnits = [.minute, .second]
        let outputTime = formatter.string(from: TimeInterval(time/1000))!
        
        cell.trackLabel?.text = self.albumTracks[indexPath.row].strTrack
        cell.timeLabel?.text = outputTime
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let time: Int = Int(self.albumTracks[indexPath.row].intDuration)!
        let formatter = DateComponentsFormatter();
        formatter.allowedUnits = [.minute, .second]
        let outputTime = formatter.string(from: TimeInterval(time/1000))!
        
        let track = self.albumTracks[indexPath.row].strTrack
        let duration = outputTime
        let artist = self.passedDetails.strArtist

        save(strTrack: track, strArtist: artist, intDuration: duration)
    }
    
}
