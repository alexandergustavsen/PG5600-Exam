//
//  TopAlbumsViewController.swift
//  Exam-PG5600-Tabbed
//
//  Created by Alexander Gustavsen on 16/10/2019.
//  Copyright © 2019 Alexander Gustavsen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TopAlbumsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var albumsTableView: UITableView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var topAlbums: [TopAlbums] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumsTableView.dataSource = self
        albumsTableView.delegate = self
        albumsTableView.register(UINib(nibName: "AlbumsTableViewCell", bundle: nil), forCellReuseIdentifier: "albumCell")
        
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
        albumCollectionView.register(UINib(nibName: "AlbumsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "albumColCell")
        
        fetchAlbums()
    }
    
    //PARSING
    func fetchAlbums() {
        DispatchQueue.main.async {
        Alamofire.request("https://theaudiodb.com/api/v1/json/1/mostloved.php?format=album&format=album").responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let data = json["loved"]
                    data.array?.forEach({ (album) in
                        let album = TopAlbums(
                            strAlbum: album["strAlbum"].stringValue,
                            strArtist: album["strArtist"].stringValue,
                            strAlbumThumb: album["strAlbumThumb"].stringValue
                        )
                        self.topAlbums.append(album)
                    })
                    self.albumsTableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
            
        }
    }
    
    //TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = albumsTableView.dequeueReusableCell(withIdentifier: "albumCell") as! AlbumsTableViewCell
        cell.albumLabel?.text = self.topAlbums[indexPath.row].strAlbum
        cell.artistLabel?.text = self.topAlbums[indexPath.row].strArtist
        
        return cell
    }
    
    
    //COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.topAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumColCell", for: indexPath) as! AlbumsCollectionViewCell
        
        cell.albumColLabel?.text = self.topAlbums[indexPath.row].strAlbum
        cell.artistColLabel?.text = self.topAlbums[indexPath.row].strArtist
        
        
        return cell
    }
    
    //SEGMENT
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            albumsTableView.isHidden = true
            albumCollectionView.isHidden = false
        case 1:
            albumsTableView.isHidden = false
            albumCollectionView.isHidden = true
        default:
            break
        }
    }
    
}
