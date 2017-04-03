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
        
        UsingOauth2(imgurSettings, performWithToken: { (token) in
            
            ImgurRequestConvertible.OAuthToken = token
            
        }) {
            print("Oauth2 failed")
        }
        
        reloadData(self)
    }
    
    @IBAction func pickPhoto(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func reloadData(_ sender: Any) {
        
        imageArray = [ImgurImage]()
        Alamofire.request(ImgurRequestConvertible.images()).responseJSON(completionHandler: { (response) in
            
            if let JSON:[String:Any] = response.result.value as? Dictionary {
                let imgurResponse = ImgurResponse(fromJson: JSON)
                if imgurResponse.success
                {
                    guard let data:[Any] = imgurResponse.data as? Array else {
                        print("no data found")
                        return
                    }
                    for img in data
                    {
                        self.imageArray.append(ImgurImage(json: img as! Dictionary<String, Any>))
                    }
                    self.collectionView?.reloadData()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title: nil, message: "Please wait while image is being uploaded...", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            let jpegCompressionQuality: CGFloat = 0.9
            if let base64String = UIImageJPEGRepresentation(image, jpegCompressionQuality)?.base64EncodedString() {
                Alamofire.request(
                    ImgurRequestConvertible.postImage(
                        parameters: ["image":base64String,"type":"base64"])).responseJSON(completionHandler: { (response) in
                            
                            if let JSON:[String:Any] = response.result.value as? Dictionary {

                                let imgurResponse = ImgurResponse(fromJson: JSON)
                                if imgurResponse.success
                                {
                                    guard let data:[String:Any] = imgurResponse.data as? Dictionary else {
                                        print("no data found")
                                        return
                                    }
                                    self.imageArray.append(ImgurImage(json: data ))
                                    self.collectionView?.reloadData()
                                    self.dismiss(animated: true, completion: nil)
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
