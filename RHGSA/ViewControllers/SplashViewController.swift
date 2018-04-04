
//
//  SplashViewController.swift
//  RHGSA
//
//  Created by Mohamed Anas on 4/1/18.
//  Copyright © 2018 Mohamed Anas. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SplashViewController: UIViewController,CheckUpdateDelegate,NVActivityIndicatorViewable {
    
    private let checkUpdate = CheckUpdate()
    private let dbManager = DBManager()
    
    private var fileListDownload: [FileDownload]!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async(execute: {
            self.showAlertView()
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Show Alert
    private func showAlertView() {
        let alertController = UIAlertController(title: "Would you like to update the app content now?", message: nil, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
            self.checkForUpdate()
        }
        let action2 = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
            self.performSegue(withIdentifier: "SegueToMainView", sender: self)
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Check Update
    private func checkForUpdate() {
        self.showIndicator()
        if dbManager.openDatabase() {
            do {
                let result = try dbManager.database.executeQuery("select * from baseurl", values: nil)
                while result.next() {
                    Vars.baseURL = result.string(forColumn: "url")
                }
            } catch {
                print("\(error.localizedDescription)")
            }
            dbManager.database.close()
        }
        print(Vars.baseURL)
        checkUpdate.delegate = self
        checkUpdate.checkForTheUpdate()
    }
    
    // MARK: -  DataManager delegate
    func didRecieveResponse() {
    }
    func didRecieveError() {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "SegueToMainView", sender: self)
        })
    }
    func completedUpdate(havingFilesToDownload isFiles: Bool, _fileDownloads: [FileDownload]) {
        DispatchQueue.main.async(execute: {
            self.hideIndicator()
            self.fileListDownload = _fileDownloads
            self.performSegue(withIdentifier: "SegueToMainView", sender: self)
        })
    }
    
    // MARK: - Helper Methods
    private func showIndicator() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0) {
            self.startAnimating(kLoaderSize, message: "Checking for the update...", type: NVActivityIndicatorType(rawValue: 6)!)
        }
    }
    private func hideIndicator() {
        DispatchQueue.main.async(execute: {
            self.stopAnimating()
        })
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier, identifier == "SegueToMainView" {
            let mainViewController = segue.destination as! MainViewController
            mainViewController.fileListDownloads = self.fileListDownload
        }
    }

}
