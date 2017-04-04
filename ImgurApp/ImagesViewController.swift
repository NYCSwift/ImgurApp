//
//  ImagesViewController.swift
//  ImgurApp
//
//  Created by Aferdita Muriqi on 4/2/17.
//  Copyright © 2017 AM. All rights reserved.
//

import UIKit
import AlamofireOauth2
import Alamofire
import AlamofireImage

// images view controller extending collections view controller and confroming to image picker protocol as well as navigation controller protocol, which is needed by the image picker controller
class ImagesViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // declaring of variables needed within this class
    var imageArray = [ImgurImage]()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting imagepicker source and delegate
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        // calling Login API
        ImgurAPI.login { (success, result, error) in
            // if cussessfully logged in, we'll load the images for the logged in user.
            if success {
                self.loadImages()
            }
                // otherwise error handling, TODOD
            else {
                print(error!)
            }
        }
    }
    
    // navigation bar button connected to this action to show the image picker controller
    @IBAction func pickPhoto(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    //  navigation bar button connected to this Action to relaod the images
    @IBAction func reloadImages(_ sender: Any) {
        loadImages()
    }
    
    // for convenience created this method,, which is called at view did load and also at reload images
    func loadImages() {
        // initializing image array
        imageArray = [ImgurImage]()
        // calling images API , which will give us the result of all images for the current account
        ImgurAPI.images { (success, result, error) in
            // if successful, we'll add the result to the images array
            if success {
                self.imageArray = result as! [ImgurImage]
            }
                // otherwise we'll need to handle the error, TODO
            else {
                print(error!)
            }
        }
    }

    // this functionality is not ideal, but it does the job for now.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // once and image has been picked, dismissing the image picker controller
        self.dismiss(animated: true) {
            
            // showing and alert while the image is uploading 
            // this is the part which is not ideal, since i should actually find a way first to check if upload is possible.
            let alert = UIAlertController(title: nil, message: "Uploading Image. Please wait ...", preferredStyle: .alert)
            self.present(alert, animated: true) {
                
                // in the completion handler of the alert, starting upload of image
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    
                    // actual API call to upload
                    ImgurAPI.upload(image: image, completion: { (success, result, error) in
                        
                        // if upload was successful, add image to the existing array and reload collection view data
                        if success {
                            self.imageArray.append(result as! ImgurImage)
                            self.collectionView?.reloadData()
                        }
                            // otherwise handle error, which currrently is not implemented as userfacing.
                        else {
                            print(error!)
                        }
                        // once image has been upload , dismiss the alert controller
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    // number of rows in section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    // for now just simply showing the image from the given link out of the array
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ImageViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.reuseIdentifier, for: indexPath) as! ImageViewCell
        let imgurImage = imageArray[indexPath.row]
        let url = URL(string: imgurImage.link)!
        cell.imageView.af_setImage(withURL: url)
        return cell
    }
    
    // TODO - needs segue identifier
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // pass selected image to Detail View Contrller
        let controller = segue.destination as! DetailViewController
        let cell = sender as! ImageViewCell
        let indexPath = self.collectionView!.indexPath(for: cell)
        let imgurImage  = self.imageArray[indexPath!.row]
        
        // imguRImage - needed for delete
        controller.imgurImage = imgurImage
        
        // image - needed for display
        controller.image = cell.imageView.image
        
        // indexPath - needed to remove from array , when image is being deleted
        controller.indexPath = indexPath
    }
    
    // exit segue for detail view controller
    @IBAction func deleteImage(_ sender: UIStoryboardSegue) {
        // intentionally blank
    }
    
}

// custom collection view cell
class ImageViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "Cell"
    @IBOutlet var imageView: UIImageView!
    
}
