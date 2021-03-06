//
//  UserSignIn.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 2/11/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import Foundation

class UserSignIn
{
    var username: String!
    var password: String!
    
    private let errorStatus = "Sign in error"
    private let errorMessage = "Error while signing in."
    
    func signInUser(completion:(status: String, message: String) -> Void)
    {
        let url = NSURL(string: "http://localhost/DemoShop-ServerSide/userSignIn/\(username)/\(password)")!
        
        let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
        
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        
        // Send request:
        
        let task = session.dataTaskWithRequest(request) {
            
            [unowned self](data, response, error) -> Void in
            
            guard error == nil else
            {
                print("Error != nil (signInUser): \(error)")
                completion(status: self.errorStatus, message: self.errorMessage)
                return
            }
            
            if let response = response as? NSHTTPURLResponse
            {
                if response.statusCode != 200
                {
                    print("statusCode != 200 (signInUser): \(response.description)")
                    completion(status: self.errorStatus, message: self.errorMessage)
                    return
                }
            }
            
            guard data != nil else
            {
                print("Data == nil (signInUser)")
                completion(status: self.errorStatus, message: self.errorMessage)
                return
            }
            
//            let backendResponse = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("\n")
//            print("backendResponse (signInUser) => \(backendResponse)")
//            print("\n")
            
            do
            {
                // Response from server
                let jSon = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String : AnyObject]
                
                let status = jSon["status"] as! String
                
                if status != "Success"
                {
                    let message = jSon["message"] as! String
                    completion(status: status, message: message)
                    return
                }
                
                self.retrieveUserByUsername({
                    
                    (status, message) -> Void in
                    
                    completion(status: status, message: message)
                })
            }
            catch let error as NSError
            {
                print("Error try/catch (signInUser): \(error)")
                completion(status: self.errorStatus, message: self.errorMessage)
            }
        }
        
        task.resume()
    }
    
    private func retrieveUserByUsername(completion:(status: String, message: String) -> Void)
    {
        let url = NSURL(string: "http://localhost/DemoShop-ServerSide/retrieveUserByUsername/\(username)")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        
        let task = session.dataTaskWithRequest(request) {
            
            (data, response, error) -> Void in
            
            guard error == nil else
            {
                print("Error != nil (retrieveUserByUsername): \(error)")
                
                completion(status: self.errorStatus, message: self.errorMessage)
                return
            }
            
            if let response = response as? NSHTTPURLResponse
            {
                if response.statusCode != 200
                {
                    print("statusCode != 200 (retrieveUserByUsername): \(response.description)")
                    
                    completion(status: self.errorStatus, message: self.errorMessage)
                    return
                }
            }
            
            guard data != nil else
            {
                print("Data == nil (retrieveUserByUsername)")
                
                completion(status: self.errorStatus, message: self.errorMessage)
                return
            }
            
//            let backendResponse = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("\n")
//            print("backendResponse (retrieveUserByUsername) => \(backendResponse)")
//            print("\n")
            
            do
            {
                // Response from server
                let jSon = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String : AnyObject]
                
                let status = jSon["status"] as! String
                
                if status != "Success"
                {
                    completion(status: self.errorStatus, message: self.errorMessage)
                    return
                }
                
                let user = jSon["user"] as! [String : AnyObject]
                
                var userDic = [String : AnyObject]()
                    userDic["id"] = user["id"]
                    userDic["name"] = user["name"]
                    userDic["email"] = user["email"]
                    userDic["sessionStatus"] = user["sessionStatus"]
                    userDic["sessionStart"] = user["sessionStart"]
                
                let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(userDic, forKey: "currentUser")
                    defaults.synchronize()
                
                completion(status: status, message: "Successfully registered user!")
            }
            catch let error as NSError
            {
                print("Error try/catch (retrieveUserByUsername): \(error)")
                completion(status: self.errorStatus, message: self.errorMessage)
            }
        }
        
        task.resume()
    }
}