//
//  DetailViewController.swift
//  ImgurApp
//
//  Created by Aferdita Muriqi on 4/3/17.
//  Copyright © 2017 AM. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imgurImage:ImgurImage!
    var image:UIImage!
    var indexPath:IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        let alert = UIAlertController(title: nil, message: "Are your sure you want to delete this Image?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { (action) in
            
            self.performSegue(withIdentifier: identifier, sender: sender)
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
        
        return false
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let controller = segue.destination as! ImagesViewController
        ImgurAPI.deleteImage(id: imgurImage.id) { (success, result, error) in
            if success  {
                controller.imageArray.remove(at: self.indexPath.row)
                controller.collectionView?.reloadData()
            }
            else {
                print(error!)
            }
        }
    }
}
