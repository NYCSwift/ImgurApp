//
//  DetailViewController.swift
//  ImgurApp
//
//  Created by Aferdita Muriqi on 4/3/17.
//  Copyright © 2017 AM. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // declraing of outlets
    @IBOutlet weak var imageView: UIImageView!
    
    // decaling of variabled needed in this class 
    // this will need some more work, as i am setting the variables as explicit optionals, which could cause issue if not handled correctly,
    var imgurImage:ImgurImage!
    var image:UIImage!
    var indexPath:IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setting imageviews image to the selected image passed through the segue
        imageView.image = image
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        // this would need some more work, to make sure only the right segue is being handled, 
        // since this controller has no other segue connection other than the exist segue, this will not cause any issues as is. 
        
        // before continuing the deletion, we want to ask the user via alert controller if they are sure to delete
        let alert = UIAlertController(title: nil, message: "Are your sure you want to delete this Image?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { (action) in
            
            // if they are sure and want to still delete the image , we perform the segue by the identifier
            self.performSegue(withIdentifier: identifier, sender: sender)
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
        
        return false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // this would need some more work, to make sure only the right segue is being handled,
        // since this controller has no other segue connection other than the exist segue, this will not cause any issues as is.

        // wheh the exit segue is being performed, the selected image will bedeleted via API
        let controller = segue.destination as! ImagesViewController
        ImgurAPI.deleteImage(id: imgurImage.id) { (success, result, error) in
            // if deletion was successful, we remove the selected image from the images array 
            // and reload the collectionview
            if success  {
                controller.imageArray.remove(at: self.indexPath.row)
                controller.collectionView?.reloadData()
            }
                // otherwise we handle the error TODO
            else {
                print(error!)
            }
        }
    }
}
