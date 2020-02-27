//
//  TopAlbumsViewController.swift
//  Exam-PG5600-Tabbed
//

import UIKit
import Alamofire
import SwiftyJSON

class TopAlbumsViewController: UIViewController {
    
    @IBOutlet weak var albumsTableView: UITableView!
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var topAlbums: [AlbumData] = []
    var detailsToPass: AlbumData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumsTableView.dataSource = self
        albumsTableView.delegate = self
        albumsTableView.register(UINib(nibName: "AlbumsTableViewCell", bundle: nil), forCellReuseIdentifier: "albumCell")
        
        albumsCollectionView.dataSource = self
        albumsCollectionView.delegate = self
        albumsCollectionView.register(UINib(nibName: "AlbumsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "albumColCell")
        
        fetchAlbums()
    }
    
    //PARSING
    func fetchAlbums() {
        DispatchQueue.main.async {
            Alamofire.request("https://theaudiodb.com/api/v1/json/1/mostloved.php?format=album&format=album").responseJSON(completionHandler: {
                (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let data = json["loved"]
                    data.array?.forEach({ (album) in
                        let album = AlbumData(
                            idAlbum: album["idAlbum"].stringValue,
                            strAlbum: album["strAlbum"].stringValue,
                            strArtist: album["strArtist"].stringValue,
                            strAlbumThumb: album["strAlbumThumb"].stringValue,
                            intYearReleased: album["intYearReleased"].stringValue
                        )
                        self.topAlbums.append(album)
                    })
                    self.albumsTableView.reloadData()
                    self.albumsCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    //SEGMENT
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            albumsTableView.isHidden = true
            albumsCollectionView.isHidden = false
        case 1:
            albumsTableView.isHidden = false
            albumsCollectionView.isHidden = true
        default:
            break
        }
    }
    
    //SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "segueDetailView") {
            let viewController = segue.destination as! DetailViewController
            viewController.passedDetails = detailsToPass
        }
    }
}

extension TopAlbumsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = albumsTableView.dequeueReusableCell(withIdentifier: "albumCell") as! AlbumsTableViewCell
        
        cell.albumLabel?.text = self.topAlbums[indexPath.row].strAlbum
        cell.artistLabel?.text = self.topAlbums[indexPath.row].strArtist
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let albumDetails = self.topAlbums[indexPath.row]
        detailsToPass = albumDetails
        
        self.performSegue(withIdentifier: "segueDetailView", sender: self)
    }
    
}

extension TopAlbumsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.topAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumsCollectionView.dequeueReusableCell(withReuseIdentifier: "albumColCell", for: indexPath) as! AlbumsCollectionViewCell
        
        let image = self.topAlbums[indexPath.row].strAlbumThumb
        var downloadURL = NSURL()
        
        if(image != ""){
            downloadURL = NSURL(string: image)!
        } else {
            downloadURL = NSURL(string: "https://secureservercdn.net/166.62.112.193/zzp.779.myftpupload.com/wp-content/uploads/woocommerce-placeholder-700x700.png")!
        }
        
        cell.imageView.af_setImage(withURL: downloadURL as URL)
        cell.albumColLabel?.text = self.topAlbums[indexPath.row].strAlbum
        cell.artistColLabel?.text = self.topAlbums[indexPath.row].strArtist
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let albumDetails = self.topAlbums[indexPath.row]
        detailsToPass = albumDetails
        
        self.performSegue(withIdentifier: "segueDetailView", sender: self)
    }
}

extension TopAlbumsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat((albumsCollectionView.frame.size.width / 2) - 20), height: CGFloat((albumsCollectionView.frame.size.width / 2) - 20))
    }
}


