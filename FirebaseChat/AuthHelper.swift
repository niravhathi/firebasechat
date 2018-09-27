//
//  AuthProvider.swift
//  FirebaseChat
//
//  Created by DSPL on 26/09/18.
//  Copyright © 2018 Nirav Hathi. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ message: String?) -> Void

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid email address, please provide a valid email address."
    static let WRONG_PASSWORD = "Wrong password. Please enter the correct password."
    static let PROBLEM_CONNECTING = "Problem connecting to database. Please try again later."
    static let USER_NOT_FOUND = "User not found. Please register."
    static let EMAIL_ALREADY_IN_USE = "Email is already in use."
    static let WEAK_PASSWORD = "Password must be at least 6 characters long."
}

class AuthHelper {
    
    private static let _instance = AuthHelper()
    
    static var Instance: AuthHelper {
        return _instance
    }
    
    var userName = ""
    
    func logIn(email: String, password: String, loginHandler: LoginHandler?) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleErrors(error: error as! NSError, loginHandler: loginHandler)
            } else {
                loginHandler?(nil)
            }
        })
    }
    
    func register(email: String, password: String,name:String, loginHandler: LoginHandler?){
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.handleErrors(error: error as! NSError, loginHandler: loginHandler)
            } else {
                if user?.uid != nil {
                    
                    DatabaseHelper.Instance.saveUser(withID: user!.uid, email: email, name: name)
                    
                    self.logIn(email: email, password: password, loginHandler: loginHandler)
                }
            }
        })
    }
    
    func isLoggedIn() -> Bool {
        if FIRAuth.auth()?.currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    func logOut() -> Bool {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                return true
            } catch {
                return false
            }
        }
        return true
    }
    
    func userId() -> String {
        
        guard let currentUser = FIRAuth.auth()?.currentUser else { return "" }
        
        return currentUser.uid
    }
    
    private func handleErrors(error: NSError, loginHandler: LoginHandler?) {
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            
            switch errorCode {
            case .errorCodeWrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD)
                break
            case .errorCodeInvalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL)
                break
            case .errorCodeUserNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND)
                break
            case .errorCodeEmailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE)
                break
            case .errorCodeWeakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD)
                break
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING)
                break
            }
        }
        
    }
}
