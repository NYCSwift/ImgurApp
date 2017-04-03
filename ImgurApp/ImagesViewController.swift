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

private let reuseIdentifier = "Cell"

class ImagesViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageArray = [ImgurImage]()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        ImgurAPI.login { (success, result, error) in
            if success {
                self.loadImages()
            }
            else {
                print(error!)
            }
        }
    }
    
    @IBAction func pickPhoto(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func reloadImages(_ sender: Any) {
        loadImages()
    }
    
    func loadImages() {
        imageArray = [ImgurImage]()
        ImgurAPI.images { (success, result, error) in
            if success {
                self.imageArray = result as! [ImgurImage]
            }
            else {
                print(error!)
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true) {
            
            let alert = UIAlertController(title: nil, message: "Uploading Image. Please wait ...", preferredStyle: .alert)
            self.present(alert, animated: true) {
                
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    
                    ImgurAPI.upload(image: image, completion: { (success, result, error) in
                        
                        if success {
                            self.imageArray.append(result as! ImgurImage)
                            self.collectionView?.reloadData()
                        }
                        else {
                            print(error!)
                        }
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ImageViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageViewCell
        let imgurImage = imageArray[indexPath.row]
        let url = URL(string: imgurImage.link)!
        cell.imageView.af_setImage(withURL: url)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! DetailViewController
        let cell = sender as! ImageViewCell
        let indexPath = self.collectionView!.indexPath(for: cell)
        let imgurImage  = self.imageArray[indexPath!.row]
        controller.imgurImage = imgurImage
        controller.image = cell.imageView.image
        controller.indexPath = indexPath
    }
    
    @IBAction func deleteImage(_ sender: UIStoryboardSegue) {
        // exit segue for detail view controller
    }
    
}

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
}
