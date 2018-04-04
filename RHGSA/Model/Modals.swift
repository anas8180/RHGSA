//
//  Modals.swift
//  RHGSA
//
//  Created by Mohamed Anas on 4/3/18.
//  Copyright © 2018 Mohamed Anas. All rights reserved.
//

import Foundation

struct FileValues {
    var fileid: String
    var hotid: String
    var filetype: String
    var fileheader: String
    var filename: String
    var filename2: String
    var stat: String
    var active: String
    var title: String
    var typename: String
    var selected: Int
    var sendemail: Int
    var showonlist: Int
    var showtitle: Int
    var animated: Int = 0
    var noquestion: Int = 0
    var noanswer: Int = 0
    var index: Int = 0
    var type: Int
    var answer: String
    var correct: String
    var iscorrect: Int
    var link: String
    var activityid: String
}
    
struct MenuFiles {
    var fileid: String
    var active: String
    var fileheader: String
    var hotid: String
    var title: String
    var activityid: String
}

struct GalleryFiles {
    var activityid: String
    var type: String
    var filename2: String
    var fileid: String
    var filetype: String
    var hotid: String
    var fileheader: String
    var filename: String
    var active: String
}
