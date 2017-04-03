//
//  ImgurApiClient.swift
//  ImgurApp
//
//  Created by Aferdita Muriqi on 4/2/17.
//  Copyright © 2017 AM. All rights reserved.
//

import Foundation
import AlamofireOauth2
import Alamofire

//  Client ID           Client Secret
//  ebda7db396bc4a0     9e4d324e47e5933b43d9c9dccc35c49d4009c269

let imgurSettings = Oauth2Settings(
    baseURL: "https://api.imgur.com/3/",
    authorizeURL: "https://api.imgur.com/oauth2/authorize",
    tokenURL: "https://api.imgur.com/oauth2/token",
    redirectURL: "https://imgur.com",
    clientID: "ebda7db396bc4a0",
    clientSecret: "9e4d324e47e5933b43d9c9dccc35c49d4009c269"
)

public enum ImgurRequestConvertible: URLRequestConvertible {
    
    //    GET
    //    https://api.imgur.com/3/account/me
    case me()
    
    //    GET
    //    https://api.imgur.com/3/account/me/images
    case images()
    
    //    POST
    //    https://api.imgur.com/3/image
    //    image	required	A binary file, base64 data, or a URL for an image. (up to 10MB)
    case postImage(parameters: Parameters)
    
    //    DELETE
    //    https://api.imgur.com/3/image/{id}
    case deleteImage(imageId: String)
    
    
    static let baseURLString = imgurSettings.baseURL
    static var OAuthToken: String?
    
    var method: HTTPMethod {
        switch self {
        case .me:
            return .get
        case .images:
            return .get
        case .postImage:
            return .post
        case .deleteImage:
            return .delete
        }
    }
    var path: String {
        switch self {
        case .me:
            return "account/me"
        case .images:
            return "account/me/images"
        case .postImage:
            return "image"
        case .deleteImage(let id):
            return "image/\(id)"
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        
        let url = try ImgurRequestConvertible.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        urlRequest.httpMethod = method.rawValue
        
        if let token = ImgurRequestConvertible.OAuthToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case .me:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .images:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .deleteImage:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .postImage(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
        
    }
}

class ImgurImage {
    var id:String
    var link:String
    
    init(json:Dictionary<String, Any>) {
        
        self.id = json["id"] as! String
        self.link = json["link"] as! String
        
    }
}

class ImgurResponse {
    var data:Any
    var status:Int
    var success:Bool
    
    init(fromJson json:Dictionary<String, Any>)
    {
        self.data = json["data"]!
        self.status = json["status"] as! Int
        self.success = json["success"] as! Bool
    }
}


