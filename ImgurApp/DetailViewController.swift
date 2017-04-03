//
//  DetailViewController.swift
//  ImgurApp
//
//  Created by Aferdita Muriqi on 4/3/17.
//  Copyright © 2017 AM. All rights reserved.
//

import UIKit
import AlamofireOauth2
import Alamofire

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
        Alamofire.request(ImgurRequestConvertible.deleteImage(imageId: imgurImage.id)).responseJSON(completionHandler: { (response) in
            
            if let JSON:[String:Any] = response.result.value as? Dictionary {

                let imgurResponse = ImgurResponse(fromJson: JSON)
                if imgurResponse.success
                {
                    controller.imageArray.remove(at: self.indexPath.row)
                    controller.collectionView?.reloadData()
                }
                else
                {
                    print("something went wrong") // handle errors
                }
            }
            else
            {
                print("something went wrong") // handle errors
            }
        })
    }
}
