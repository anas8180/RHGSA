//
//  MainViewController.swift
//  RHGSA
//
//  Created by Mohamed Anas on 4/3/18.
//  Copyright © 2018 Mohamed Anas. All rights reserved.
//

import UIKit

class MainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    var fileListDownloads: [FileDownload]!
        
    @IBOutlet weak var downloadingLable: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHt: NSLayoutConstraint!

    private var sideMenuData: [MenuFiles]!
    private var galleryData: [GalleryFiles]!
   
    private let dbManager = DBManager()
    private let checkUpdate = CheckUpdate()

    var downloadCount = 0
    
    // Create downloadsSession here, to set self as delegate
    let downloadService = DownloadService()
    lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        downloadService.downloadSession = downloadSession
        
        sideMenuData = []
        galleryData = []
        
        _ = checkUpdate.getSalesID()
        loadSideMenuItems()
        loadGalleryViewItems()
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        
        tableView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        downloadingLable.text = ""
        downloadCount = 0
        
        checkFileDownload()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Checking Download List
    func checkFileDownload() {
        
        if let fileLists = fileListDownloads, fileLists.count > 0 {
            downloadCount = 0
            for fileDownload in fileLists {
                downloadService.startDownload(fileDownload)
            }
            DispatchQueue.main.async(execute: {
                self.downloadingLable.text = String(format: "Downloading %d/%d", self.downloadCount,fileLists.count)
            })
        }
    }
    
    // MARK: - Gallery View Configuration
    func loadGalleryViewItems() {
        if dbManager.openDatabase() {
            do {
                let result = try dbManager.database.executeQuery("Select * from mainfiles as hf where hf.active = 1  and type = 1 order by sort asc", values: nil)
                while result.next() {
                    let galleryItems = GalleryFiles(activityid: result.string(forColumn: "activityid"),
                                                    type: result.string(forColumn: "type"),
                                                    filename2: result.string(forColumn: "filename2"),
                                                    fileid: result.string(forColumn: "fileid"),
                                                    filetype: (result.string(forColumn: "filetype") != nil ? result.string(forColumn: "filetype") : ""),
                                                    hotid: result.string(forColumn: "hotid"),
                                                    fileheader: result.string(forColumn: "fileheader"),
                                                    filename: result.string(forColumn: "filename"),
                                                    active: result.string(forColumn: "active"))
                    galleryData.append(galleryItems)
                }
                DispatchQueue.main.async(execute: {
                    self.collectionView.reloadData()
                })
            } catch {
                print(error.localizedDescription)
            }
            dbManager.database.close()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (galleryData != nil) ? galleryData.count : 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GalleryView
        
        cell.backgroundColor = UIColor(named: "rhgsa_black")
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.red.cgColor

        let fileManager = FileManager.default
        
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/\(galleryData[indexPath.row].filename2)")
        
        if fileManager.fileExists(atPath: filePath) {
            cell.placeHolderImageView.isHidden = true
            cell.galleryImageView.isHidden = false
            
            cell.galleryImageView.contentMode = .scaleToFill
            cell.galleryImageView.image = UIImage(contentsOfFile: filePath)
        }
        else {
            cell.placeHolderImageView.isHidden = false
            cell.galleryImageView.isHidden = true
            
            cell.placeHolderImageView.contentMode = .scaleAspectFit
            cell.placeHolderImageView.image = #imageLiteral(resourceName: "gallery")
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        var cellSize = CGSize(width: 0, height: 0)
        
        switch screenSize.width {
        case 480:
            cellSize = CGSize(width: 148, height: 110)
            break
        case 568:
            cellSize = CGSize(width: 175, height: 120)
            break
        case 667:
            cellSize = CGSize(width: 210, height: 150)
            break
        case 736:
            cellSize = CGSize(width: 230, height: 150)
            break
        case 812:
            cellSize = CGSize(width: 232, height: 165)
            break
        case 1024:
            cellSize = CGSize(width: 329, height: 250)
            break
        case 1366:
            cellSize = CGSize(width: 443, height: 300)
        default:
            break
        }
        
        return cellSize
    }
    
    // MARK: - SideMenu Configurations
    func loadSideMenuItems() {
        if dbManager.openDatabase() {
            do {
                let result = try dbManager.database.executeQuery("select * from mainmenu where active = 1 order by cast(sort as real) asc", values: nil)
                while result.next() {
                    let menuItems = MenuFiles(fileid: result.string(forColumn: "fileid"),
                                              active: result.string(forColumn: "active"),
                                              fileheader: result.string(forColumn: "fileheader"),
                                              hotid: result.string(forColumn: "hotid"),
                                              title: result.string(forColumn: "title"),
                                              activityid: result.string(forColumn: "activityid"))
                    sideMenuData.append(menuItems)
                }
                setTableViewHieght()
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            } catch {
                print(error.localizedDescription)
            }
            
            dbManager.database.close()
        }
    }
    func setTableViewHieght() {
        let screenSize = UIScreen.main.bounds
        let rows = sideMenuData.count
        
        var height = screenSize.height * CGFloat(rows)
        
        if screenSize.width == 102 && screenSize.width == 1366 {
            
        }
        else {
            height = screenSize.height-65
        }
        DispatchQueue.main.async(execute: {
            self.tableViewHt.constant = height
        })
        tableView.setNeedsDisplay()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sideMenuData != nil) ? sideMenuData.count : 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if sideMenuData[indexPath.row].title == "Sign In" {
            if Vars.salesid == "0" || Vars.salesid == "" {
                cell.textLabel?.text = sideMenuData[indexPath.row].title
            }
            else {
                cell.textLabel?.text = "Sign Out - " + Vars.salesname
            }
        }
        else {
            cell.textLabel?.text = sideMenuData[indexPath.row].title
        }
        return cell
    }
    
    // MARK: - Button Action
    @IBAction func menuTapped(_ sender: Any) {
        if tableView.isHidden {
            tableView.isHidden = false
            showAnimation(ofView: self.view)
        }
        else {
            tableView.isHidden = true
            showAnimation(ofView: self.view)
        }
    }
    
    // MARK: - SideMenu Show/Hide Animation
    func showAnimation(ofView aView: UIView) {
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.5
        aView.layer.add(transition, forKey: "MenuAnimation")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainViewController: URLSessionDelegate {
    // Standard background session handler
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.downloadingLable.text = ""
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

extension MainViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //1
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil

        //2
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        // 3
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download?.fileDownload.downloaded = true
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        downloadCount += 1
        
        DispatchQueue.main.async(execute: {
            if self.downloadCount == self.fileListDownloads.count {
                self.downloadingLable.text = ""
                DispatchQueue.main.async(execute: {
                    self.collectionView.reloadData()
                })
            }
            else {
                self.downloadingLable.text = String(format: "Downloading %d/%d", self.downloadCount,self.fileListDownloads.count)
            }
        })
    }
    
}
