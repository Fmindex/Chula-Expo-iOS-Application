//
//  LoginViewController.swift
//  Chula Expo 2017
//
//  Created by Pakpoom on 12/29/2559 BE.
//  Copyright © 2559 Chula Computer Engineering Batch#41. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import CoreData
import Alamofire

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var token: String?
    var name: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var fbImageProfileUrl: String?
    var fbImage: UIImage!
    
    let managedObjectContext: NSManagedObjectContext? =
        (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        if FBSDKAccessToken.current() != nil {
            
            
            checkRegisterStatus(completion: { (success, results) in
                print(success)
            })
//            self.profileUpdate()
            
        } else {
        
            createGradientLayer()
        
            createLogo()
        
            createFacebookLoginButton()
        
            createGuestLoginButton()
        
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toUserType" {
            
            let navigationController = segue.destination as! UINavigationController
            
            let destination = navigationController.viewControllers.first as! UserTypeViewController
            
            destination.token = self.token
            destination.name = self.name
            destination.firstName = self.firstName
            destination.lastName = self.lastName
            destination.email = self.email
//            registerViewController.fbImageProfileUrl = self.fbImageProfileUrl
            destination.fbImage = self.fbImage
            
        }
        
    }
    
    func prepareToRegister() {
        
        if let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email, name, first_name, last_name"]) {
            
            graphRequest.start(completionHandler: { (connection, result, error) in
                
                if error != nil {
                    
                    print(error!)
                    
                } else {
                    
                    if let userDetails = result as? [String: String] {
                        
                        self.token = FBSDKAccessToken.current().tokenString
                            
                        self.name = userDetails["name"]
                            
                        self.firstName = userDetails["first_name"]
                            
                        self.lastName = userDetails["last_name"]
                            
                        self.email = userDetails["email"]
                            
                        self.fbImageProfileUrl = "https://graph.facebook.com/\(userDetails["id"]!)/picture?type=large"
                        
                        self.setImageProfile()
                        
                        self.performSegue(withIdentifier: "toUserType", sender: self)
                        
                    }
                    
                }
                
            })
            
        }
        
    }
    
    func guestLogin() {
        
        self.name = "Yourname Lastname"
        self.fbImage = UIImage(named: "chula_expo_logo.jpg")
        
        performSegue(withIdentifier: "toHomeScreen", sender: self)
        
    }
    
    func facebookLogin() {
        
        let login: FBSDKLoginManager = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result , error) in
            
            if error != nil {
                
                print(error!)
                
            } else if (result?.isCancelled)! {
                
                print("User cancelled login")
                
            } else {
                
                if (result?.grantedPermissions.contains("email"))! {
                    
                    self.checkRegisterStatus(completion: { (success, token) in
                    
                        if success {
                            
                            let header: HTTPHeaders = ["Authorization": "JWT \(token)"]
                            /*Student*/
//                            let header: HTTPHeaders = ["Authorization": "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ODk5NmNmZmMzOGE4YzY0OTZlZTI0NDEiLCJpYXQiOjE0ODY0NDk5NjEsImV4cCI6MTQ4NjQ3ODc2MX0.lTjrWZYa3wlGllsLwiD_FoGRRuX2tSZhYU08yL6hOcY"]
                            /*Person*/
//                            let header: HTTPHeaders = ["Authorization": "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ODk5OWQ2MWMzOGE4YzY0OTZlZTI0NDQiLCJpYXQiOjE0ODY0NjIzMDUsImV4cCI6MTQ4NjQ5MTEwNX0.TbDNvBAnmESmR_UCFdxId2J4kiXSDi3rghNkQXcuYjE"]
                            
                            Alamofire.request("http://staff.chulaexpo.com/api/me", headers: header).responseJSON { response in
                                
                                let JSON = response.result.value as! NSDictionary
                                
                                if let results = JSON["results"] as? NSDictionary{
                                    
                                    let academic = results["academic"] as? [String: String]
                                    
                                    let worker = results["worker"] as? [String: String]
                                
                                    let managedObjectContext: NSManagedObjectContext? =
                                        (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
                                    
                                    managedObjectContext?.performAndWait {
                                    
                                        _ = UserData.addUser(id: results["_id"] as! String,
                                                             token: token,
                                                             type: results["type"] as! String,
                                                             name: results["name"] as! String,
                                                             email: results["email"] as! String,
                                                             age: results["age"] as! Int,
                                                             gender: results["gender"] as! String,
                                                             school: academic?["school"] ?? "",
                                                             level: academic?["level"] ?? "",
                                                             year: academic?["year"] ?? "",
                                                             job: worker?["job"] ?? "",
                                                             profile: results["profile"] as? String ?? "",
                                                             inManageobjectcontext: managedObjectContext!
                                        )
                                        
                                    }
                                    
                                    do {
                                    
                                        try managedObjectContext?.save()
                                        print("saved user")
                                        
                                    } catch let error {
                                    
                                        print("saveUserError with \(error)")
                                        
                                    }
                                    
                                    
                                }
                                
                            }
                            
                            self.performSegue(withIdentifier: "toHomeScreen", sender: self)
                            
                        } else {
                            
                            self.prepareToRegister()
                            
                        }

                    })
                    
                }
                
            }
            
        }

    }
    
    private func checkRegisterStatus(completion:@escaping (Bool, String) -> Void) {
        
        Alamofire.request("http://staff.chulaexpo.com/auth/facebook/token?access_token=\(FBSDKAccessToken.current().tokenString!)").responseJSON { response in
            //        Alamofire.request("http://staff.chulaexpo.com/auth/facebook/token?access_token=EAATpmh0ZCMDEBAJvabmtrCgufnV0ZCYWANMsF0GM8ZCRLeYnCV9oR3BnjUGkq3RWEV4GQDWKU2D1FsSvexrdBHlDAVe8fgysN5wxvCsfNYZBShhYGRN7r9SARIXrh5HlkhtCcRvv5VOEwF49pLJvEod4qhWqJLsZD").responseJSON { response in
            
            let JSON = response.result.value as! NSDictionary
            
            let success = JSON["success"] as! Bool
            
            if success {
                
                if let token = (JSON["results"] as! NSDictionary)["token"] as? String{
                    
                    completion(success, token)
                    
                }
                
            } else {
                
                completion(success, "")
                
            }
            
        }
        
    }
    
    func setImageProfile() {
        
        let facebookProfileUrl = URL(string: fbImageProfileUrl!)
        
        if let data = NSData(contentsOf: facebookProfileUrl!) {
            
            self.fbImage = UIImage(data: data as Data)
            
        }
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func createFacebookLoginButton() {
        
        let facebookLoginViewWidth = self.view.bounds.width * 0.8
        let facebookLoginViewHeight = self.view.bounds.height * 0.093
        let facebookLoginViewTopMargin = self.view.bounds.height * 0.75
        
        let facebookLoginView = UIView(frame: CGRect(x: self.view.bounds.width / 2 - facebookLoginViewWidth / 2, y: facebookLoginViewTopMargin, width: facebookLoginViewWidth, height: facebookLoginViewHeight))
        facebookLoginView.layer.cornerRadius = facebookLoginViewHeight / 2
        facebookLoginView.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20).cgColor
        
        let facebookLoginButton = UIButton(frame: CGRect(x: 0, y: 0, width: facebookLoginViewWidth, height: facebookLoginViewHeight))
        
        if self.view.bounds.height >= 667 {
            
            facebookLoginButton.titleLabel?.font = facebookLoginButton.titleLabel?.font.withSize(20)
            
        } else {
            
            facebookLoginButton.titleLabel?.font = facebookLoginButton.titleLabel?.font.withSize(17)
            
        }
        
        let facebookLoginButtonOffset = facebookLoginView.bounds.width * 0.125
        facebookLoginButton.setTitle("Login with Facebook", for: .normal)
        facebookLoginButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: facebookLoginButtonOffset, bottom: 0, right: 0)
        facebookLoginButton.setTitleColor(UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1), for: .highlighted)
        
        let facebookLogoOffset = facebookLoginView.bounds.width * 0.11
        let facebookLogo = UIImageView(frame: CGRect(x: facebookLogoOffset, y: facebookLoginView.bounds.height / 2 - 27 / 2, width: 27, height: 27))
        facebookLogo.image = UIImage(named: "facebook_logo.png")
        
        facebookLoginView.addSubview(facebookLogo)
        facebookLoginView.addSubview(facebookLoginButton)
        
        self.view.addSubview(facebookLoginView)
        
        facebookLoginButton.addTarget(self, action: #selector(LoginViewController.facebookLogin), for: .touchUpInside)
        
    }
    
    func createGuestLoginButton() {
        
        let guestLoginButtonWidth = self.view.bounds.width * 0.24
        let guestLoginButtonHeight = self.view.bounds.height * 0.053
        let guestLoginButtonTopMargin = self.view.bounds.height * 0.86
        
        let guestLoginButton = UIButton(frame: CGRect(x: self.view.bounds.width / 2 - guestLoginButtonWidth / 2, y: guestLoginButtonTopMargin, width: guestLoginButtonWidth, height: guestLoginButtonHeight))

        guestLoginButton.setTitle("Guest Mode", for: .normal)
        guestLoginButton.setTitleColor(UIColor(red: 0.03, green: 0.00, blue: 0.33, alpha: 1), for: .normal)
        guestLoginButton.setTitleColor(UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1), for: .highlighted)
        
        if self.view.bounds.height >= 667 {
            
            guestLoginButton.titleLabel?.font = guestLoginButton.titleLabel?.font.withSize(15)
            
        } else {
            
            guestLoginButton.titleLabel?.font = guestLoginButton.titleLabel?.font.withSize(12)
            
        }
        
        self.view.addSubview(guestLoginButton)
        
        guestLoginButton.addTarget(self, action: #selector(LoginViewController.guestLogin), for: .touchUpInside)
        
        
    }
    
    func createLogo() {
        
        let imageViewWidth = self.view.bounds.width * 0.613
        let imageViewHeight = self.view.bounds.height * 0.45
        let imageViewTopMargin = self.view.bounds.height * 0.15
        
        let logoImageView = UIImageView(frame: CGRect(x: self.view.bounds.width / 2 - imageViewWidth / 2, y: imageViewTopMargin, width: imageViewWidth, height: imageViewHeight))
        logoImageView.image = UIImage(named: "chula_expo_logo_white.png")
        logoImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        self.view.addSubview(logoImageView)
    }
    
    func createGradientLayer() {
        
        //Begin, define gradient layer scale
        let gradientWidth = self.view.bounds.width
        let gradientHeight = self.view.bounds.height
        //End, define
        
        //Begin, define gradient color shade from RGB(108,85,185) to RGB(202,92,171)
        let headGradientColor = UIColor(red: 0.24, green: 0.12, blue: 0.65, alpha: 1).cgColor
        let tailGradientColor = UIColor(red: 0.73, green: 0.15, blue: 0.57, alpha: 1).cgColor
        //
        
        //Begin, create gradient layer with 2 colors shade and start gradient from left to right
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: gradientWidth, height: gradientHeight)
        gradientLayer.colors = [headGradientColor, tailGradientColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0)
        //End
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }

}
