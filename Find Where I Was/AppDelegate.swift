	//
//  AppDelegate.swift
//  Where Was I
//
//  Created by Glenn McCartney on 17/11/2015.
//  Copyright © 2015 Glenn McCartney. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Google Analytics.....
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        gai?.logger.logLevel = GAILogLevel.none  // remove before app release
        // Google Analytics.....
        
        
        
        
        
        //Set NSURLIsExcludedFromBackupKey key on all files in LibraryDirectory
        var directories = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        if let libraryDirectory = directories.first {
            do {
                let documents = try FileManager.default.contentsOfDirectory(atPath: libraryDirectory)
                
                for files in documents {
                    let urlForm = URL(fileURLWithPath: libraryDirectory + "/" + files)
                    
                    do{
                        try  FileManager.default.addSkipBackupAttributeToItemAtURL(URL(fileURLWithPath: urlForm.path));
                    }
                    catch{
                         print ("Error setting RO attribute")
                    }
                }
            }
            catch { print("can't retrieve contents")
            }
        }
        directories = [""]
        //Set NSURLIsExcludedFromBackupKey key on all files in LibraryDirectory
        
        
        
        
        //List contents of documentDirectory including state of NSURLIsExcludedFromBackupKey key
        /*
            print("Listing contents of documentDirectory...")
            
            directories = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
            
            if let documentDirectory = directories.first {
                do {
                    let documents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentDirectory)
                    
                    for files in documents {
                        let urlForm = NSURL.fileURLWithPath(documentDirectory + "/" + files)
                        do {
                            try print("\(files): \(urlForm.resourceValuesForKeys([NSURLIsExcludedFromBackupKey]))")
                        }
                            
                        catch { print("can't find key") }
                    }
                }
                catch { print("can't retrieve contents")
                }
            }
            print("Finished Listing contents of documentDirectory...")
        */
        //List contents of documentDirectory including state of NSURLIsExcludedFromBackupKey key
        
        
        
        
        //List contents of LibraryDirectory including state of NSURLIsExcludedFromBackupKey key
        /*
            print("Listing contents of LibraryDirectory...")
            
            directories = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
            
            if let libraryDirectory = directories.first {
                do {
                    let documents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(libraryDirectory)
                    
                    for files in documents {
                        let urlForm = NSURL.fileURLWithPath(libraryDirectory + "/" + files)
                        do {
                            try print("\(files): \(urlForm.resourceValuesForKeys([NSURLIsExcludedFromBackupKey]))")
                        }
                            
                        catch { print("can't find key") }
                    }
                }
                catch { print("can't retrieve contents")
                }
            }
            print("Finished Listing contents of LibraryDirectory...")
        
        //List contents of LibraryDirectory including state of NSURLIsExcludedFromBackupKey key
        */
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

   
}   
    
    extension FileManager{
        func addSkipBackupAttributeToItemAtURL(_ url:URL) throws {
            try (url as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
        }
    }

