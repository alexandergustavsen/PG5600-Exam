//
//  SearchViewController.swift
//  Exam-PG5600-Tabbed
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    var filteredAlbums: [AlbumData] = []
    var detailsToPass: AlbumData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCollectionView.dataSource = self
        searchCollectionView.delegate = self
        searchCollectionView.register(UINib(nibName: "AlbumsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "albumColCell")
        
    }
    
    //PARSING
    func searchAlbums(query: String) {
        DispatchQueue.main.async {
            Alamofire.request("https://theaudiodb.com/api/v1/json/1/searchalbum.php?a=\(query)").responseJSON(completionHandler: {
                (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let data = json["album"]
                    data.array?.forEach({ (album) in
                        let album = AlbumData(
                            idAlbum: album["idAlbum"].stringValue,
                            strAlbum: album["strAlbum"].stringValue,
                            strArtist: album["strArtist"].stringValue,
                            strAlbumThumb: album["strAlbumThumb"].stringValue,
                            intYearReleased: album["intYearReleased"].stringValue
                        )
                        self.filteredAlbums.append(album)
                    })
                    self.searchCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
            
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

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "albumColCell", for: indexPath) as! AlbumsCollectionViewCell
        
        let image = self.filteredAlbums[indexPath.row].strAlbumThumb
        var downloadURL = NSURL()
        
        if(image != ""){
            downloadURL = NSURL(string: image)!
        } else {
            downloadURL = NSURL(string: "https://secureservercdn.net/166.62.112.193/zzp.779.myftpupload.com/wp-content/uploads/woocommerce-placeholder-700x700.png")!
        }
        
        if(filteredAlbums.isEmpty) {
            print("Filter is empty.")
        } else {
            cell.imageView.af_setImage(withURL: downloadURL as URL)
            cell.albumColLabel?.text = self.filteredAlbums[indexPath.row].strAlbum
            cell.artistColLabel?.text = self.filteredAlbums[indexPath.row].strArtist
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumDetails = self.filteredAlbums[indexPath.row]
        detailsToPass = albumDetails
        
        self.performSegue(withIdentifier: "segueDetailView", sender: self)
    }
    
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat((searchCollectionView.frame.size.width / 2) - 20), height: CGFloat((searchCollectionView.frame.size.width / 2) - 20))
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchAlbums(query: searchText)
        filteredAlbums = []
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
