//
//  Download.swift
//  RHGSA
//
//  Created by Mohamed Anas on 4/2/18.
//  Copyright © 2018 Mohamed Anas. All rights reserved.
//

import Foundation

class Download {
    var fileDownload: FileDownload
   
    init(fileDownload: FileDownload) {
        self.fileDownload = fileDownload
    }
    
    var task: URLSessionDownloadTask?
    var isDownloading = false

}
