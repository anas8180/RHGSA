//
//  CheckUpdate.swift
//  RHGSA
//
//  Created by Mohamed Anas on 4/2/18.
//  Copyright © 2018 Mohamed Anas. All rights reserved.
//

import UIKit

protocol CheckUpdateDelegate: class {
    func didRecieveResponse()
    func didRecieveError()
    func completedUpdate(havingFilesToDownload isFiles: Bool, _fileDownloads: [FileDownload])
}

class CheckUpdate: NSObject {

    weak var delegate: CheckUpdateDelegate?
    private let dbManager = DBManager()
    
    func checkForTheUpdate() {
        Vars.stat = getStatus()

        let url = URL(string: Vars.baseURL + "checkupdates.aspx")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let parameters = ["perid":getSalesID(),"stat":Vars.stat,"baseurl":Vars.baseURL,"transtype":Vars.transtype] as [String : Any]
        guard let parameterJson = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        
        let param = String(data: parameterJson, encoding: .utf8)
        request.httpBody = param?.data(using: .utf8)
        let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                self.delegate?.didRecieveError()
                return
            }
            let responseString = String(data: data!, encoding: .utf8)
            self.delegate?.didRecieveResponse()
            self.handleResponseFromHttpPost(response: responseString!)
        }
        session.resume()
    }
    
    // MARK: - Get Sales Person Details
    func getSalesID() -> String {
        if dbManager.openDatabase() {
            do {
                let result = try dbManager.database.executeQuery("SELECT * FROM personnel", values: nil)
                while result.next() {
                    Vars.salesname = result.string(forColumn: "pername")
                    Vars.userlevel = result.string(forColumn: "userlevel")
                    Vars.salesid = result.string(forColumn: "perid")
                    return result.string(forColumn: "perid")
                }
            } catch {
                print(error.localizedDescription)
            }
            
            dbManager.database.close()
        }
        return ""
    }
    func getStatus() -> String {
        if dbManager.openDatabase() {
            do {
                let result = try dbManager.database.executeQuery("SELECT stat FROM status", values: nil)
                while result.next() {
                    return result.string(forColumn: "stat")
                }
            } catch {
                print(error.localizedDescription)
            }
            
            dbManager.database.close()
        }
        return ""
    }
    
    // MARK: - Handle Response
    func handleResponseFromHttpPost(response: String) {
        if response.range(of: "[baseurl]") != nil {
            Vars.baseURL = response.replacingOccurrences(of: "[baseurl]", with: "")
            if dbManager.openDatabase() {
                if !dbManager.database.executeUpdate("UPDATE baseurl SET url=?", withArgumentsIn: [Vars.baseURL]) {
                    print(dbManager.database.lastError(), dbManager.database.lastErrorMessage())
                }
                dbManager.database.close()
            }
            checkForTheUpdate()
        }
        else if response.range(of: "[Error]") != nil {
            delegate?.didRecieveError()
        }
        else {
            let tables = response.components(separatedBy: "^")
            var rows = [String]()
            var cols = [String]()
            var strQuery = ""
            var ctr = 0
            
            for table in tables {
                rows = table.components(separatedBy: "~")
                if ctr == 0 {
                    dbManager.executeQuery(query: "DELETE FROM brand")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "INSERT INTO brand (brdid,brdname,active) VALUES("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if ctr == 1 {
                    dbManager.executeQuery(query: "DELETE FROM category")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "INSERT INTO category (catid,catname,active) VALUES("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if ctr == 2 {
                    dbManager.executeQuery(query: "DELETE FROM city")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "INSERT INTO city (cityid,countid,cityname,active) VALUES("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 3) {
                    dbManager.executeQuery(query: "delete from country")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into country (countid,countname,active) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 4) {
                    dbManager.executeQuery(query: "delete from hotel");
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into hotel (hotid,hotcode,hotname,brdid,catid,cityid,hotdesc,hotloc,hotdist,hotemail,hotphone,hoturl,hotbookurl,hotmeetexp,hotfacilities,hotnorooms,active) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ",'" + cols[7] + "'"
                            strQuery += ",'" + cols[8] + "'"
                            strQuery += ",'" + cols[9] + "'"
                            strQuery += ",'" + cols[10] + "'"
                            strQuery += ",'" + cols[11] + "'"
                            strQuery += ",'" + cols[12] + "'"
                            strQuery += ",'" + cols[13] + "'"
                            strQuery += ",'" + cols[14] + "'"
                            strQuery += ",'" + cols[15] + "'"
                            strQuery += ",'" + cols[16] + "'"
                            strQuery += ");"
                            
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 5) {
                    dbManager.executeQuery(query: "delete from filetype")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            
                            strQuery = ""
                            strQuery += "Insert Into filetype (typeid,typename,sort,hotelbase,active,activityid) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 6) {
                    dbManager.executeQuery(query: "delete from hotelfiles")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into hotelfiles (fileid,filetype,fileheader,filename,stat,hotid,active,sort,meeting,rooms,type,sendemail,showonlist) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ",'" + cols[7] + "'"
                            strQuery += ",'" + cols[8] + "'"
                            strQuery += ",'" + cols[9] + "'"
                            strQuery += ",'" + cols[10] + "'"
                            strQuery += ",'" + cols[11] + "'"
                            strQuery += ",'" + cols[12] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 7) {
                    dbManager.executeQuery(query: "delete from banners")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into banners (banner1,banner2,banner3,banner4) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 8) {
                    dbManager.executeQuery(query: "delete from mainfiles")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into mainfiles (fileid,hotid,fileheader,filename,filename2,activityid,stat,sort,type,active) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ",'" + cols[7] + "'"
                            strQuery += ",'" + cols[8] + "'"
                            strQuery += ",'" + cols[9] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 9) {
                    dbManager.executeQuery(query: "delete from hotelcategory")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into hotelcategory (hotid,catid) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 10) {
                    dbManager.executeQuery(query: "delete from states")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into states (stateid,countid,statename,active) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 11) {
                    dbManager.executeQuery(query: "delete from langs")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into langs (langid,langname,active) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 12) {
                    dbManager.executeQuery(query: "delete from page")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into page (pageid,title,info,active,filename,showonlist,activityid,hotid,type,sort) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ",'" + cols[7] + "'"
                            strQuery += ",'" + cols[8] + "'"
                            strQuery += ",'" + cols[9] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 13) {
                    dbManager.executeQuery(query: "delete from pagefiles")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into pagefiles (pagefileid,pageid,filename,title,url,sort,showtitle,active) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ",'" + cols[7] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 14) {
                    dbManager.executeQuery(query: "delete from quizgroup")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into quizgroup (quizgroupid,title,filename,stat,sort,finished,timelimit,active,retest,noquestion,noanswer,type) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ",'" + cols[7] + "'"
                            strQuery += ",'" + cols[8] + "'"
                            strQuery += ",'" + cols[9] + "'"
                            strQuery += ",'" + cols[10] + "'"
                            strQuery += ",'" + cols[11] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 15) {
                    dbManager.executeQuery(query: "delete from quiz")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into quiz (quizid,quizgroupid,question,nochoices,answer0,answer1,answer2,answer3,sort,answer) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ",'" + cols[7] + "'"
                            strQuery += ",'" + cols[8] + "'"
                            strQuery += ",'" + cols[9] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 16) {
                    dbManager.executeQuery(query:"delete from activity");
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into activity (activityid,title,info,activity,active,filter,sort) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 17) {
                    dbManager.executeQuery(query: "delete from activityfiles")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into activityfiles (activityfileid,activityid,filename,title,url,showtitle,sort,active) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ",'" + cols[7] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 18) {
                    dbManager.executeQuery(query: "delete from mainmenu")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into mainmenu (fileid,hotid,fileheader,activityid,stat,sort,title,active) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ",'" + cols[7] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 19) {
                    dbManager.executeQuery(query: "delete from hotelactivity")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into hotelactivity (hotid,activityid) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 20) {
                    dbManager.executeQuery(query: "delete from countryactivity")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into countryactivity (countid,activityid) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 21) {
                    dbManager.executeQuery(query: "delete from appsection")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into appsection (appsecid,appsecname,appsecdesc,view) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 22) {
                    dbManager.executeQuery(query: "delete from appsectionpage")
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into appsectionpage (appsecpageid,appsecid,appsecpagename,appsecpagedesc,imgfilename,imgfilename2,sort) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                }
                else if (ctr == 23) {
                    dbManager.executeQuery(query: "delete from appsectionpagelink");
                    for row in rows {
                        cols = row.components(separatedBy: "|")
                        if cols.count > 1 {
                            strQuery = ""
                            strQuery += "Insert Into appsectionpagelink (appsecpagelinkid,appsecpageid,appsecpagelinkname,appsecpagelinkdesc,filename,showonlist,sendemail,sort) Values("
                            strQuery += "'" + cols[0] + "'"
                            strQuery += ",'" + cols[1] + "'"
                            strQuery += ",'" + cols[2] + "'"
                            strQuery += ",'" + cols[3] + "'"
                            strQuery += ",'" + cols[4] + "'"
                            strQuery += ",'" + cols[5] + "'"
                            strQuery += ",'" + cols[6] + "'"
                            strQuery += ",'" + cols[7] + "'"
                            strQuery += ");"
                            dbManager.executeQuery(query: strQuery)
                        }
                    }
                    
                    if dbManager.openDatabase() {
                        do {
                            let result = try dbManager.database.executeQuery("Select * from appsectionpagelink as apl left join appsectionpage as ap on ap.appsecpageid = apl.appsecpageid left join appsection as a on ap.appsecid = a.appsecid order by appsecname, ap.sort, apl.sort asc", values: nil)
                            while result.next() {
                                strQuery = "";
                                strQuery += "Insert Into hotelfiles (fileid,filetype,fileheader,filename,stat,hotid,active,sort,meeting,rooms,type,sendemail,showonlist) Values(";
                                strQuery += "'" + result.string(forColumn: "appsecpagelinkid") + "'"
                                strQuery += ",'" + "18" + "'"
                                strQuery += ",'" + result.string(forColumn: "appsecname") + " - " + result.string(forColumn: "appsecpagename") + " - " + result.string(forColumn: "appsecpagelinkname") + "'"
                                strQuery += ",'" + result.string(forColumn: "filename") + "'"
                                strQuery += ",'" + Vars.stat + "'"
                                strQuery += ",'" + "-1" + "'"
                                strQuery += ",'" + "1" + "'"
                                strQuery += ",last_insert_rowid() + 1"
                                strQuery += ",'" + "0" + "'"
                                strQuery += ",'" + "0" + "'"
                                strQuery += ",'" + "1" + "'"
                                strQuery += ",'" + "1" + "'"
                                strQuery += ",'" + "1" + "'"
                                strQuery += ");"
                                dbManager.database.executeStatements(strQuery)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                        dbManager.database.close()
                    }
                }
                ctr += 1
            }
            Vars.salesid = getSalesID()
            if dbManager.openDatabase() {
                do {
                    let result = try dbManager.database.executeQuery("Select * from quizgrouptransmit where perid = '" + Vars.salesid + "' and userlevel = '" + Vars.userlevel + "'", values: nil)
                    while result.next() {
                        let answers = result.string(forColumn: "answers").components(separatedBy: "~")
                        for index in 0..<answers.count {
                            let vals = answers[index].components(separatedBy: ",")
                            try dbManager.database.executeUpdate("Update quiz set answer = ? where quizid = ?", values: [vals[1],vals[0]])
                        }
                        try dbManager.database.executeUpdate("update quizgroup set noanswer = ? where quizgroupid = ?", values: [answers.count,result.string(forColumn: "quizgroupid")])
                    }
                } catch {
                    print(error.localizedDescription)
                }
                dbManager.database.close()
            }
            Vars.stat = tables[tables.count - 1]
            checkFilesToDownload(updateStatus: tables[tables.count - 1])
        }
    }
    
    // MARKR: - Getting downloading URL
    func checkFilesToDownload(updateStatus: String) {
        var ctrfiles = 0
        var filename = ""
        var downloadList = [FileDownload]()
        
        let fileManager = FileManager.default

        if dbManager.openDatabase() {
            do {
                let result = try dbManager.database.executeQuery("Select * from quizgroup where type = 1 or type = 2", values: nil)
                while result.next() {
                    
                    filename = result.string(forColumn: "filename")
                    let fileURL = URL(string: Vars.baseURL.appending("files/\(filename)"))
                    
                    var fileSavedPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    fileSavedPath = fileSavedPath.appending("/\(filename)")
                    if !(fileManager.fileExists(atPath: fileSavedPath)) {
                        downloadList.append(FileDownload(fileName: filename, fileURL: fileURL!))
                        ctrfiles += 1
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
            do {
                let result = try dbManager.database.executeQuery("Select * from hotelfiles as hf inner join filetype as f on filetype = typeid where hf.type = 1 and  hf.active = 1 and f.active = 1 order by f.sort, hf.sort asc, hf.fileheader, hf.filename", values: nil)
                while result.next() {
                    
                    filename = result.string(forColumn: "filename")
                    let fileURL = URL(string: Vars.baseURL.appending("files/\(filename)"))
                    
                    var fileSavedPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    fileSavedPath = fileSavedPath.appending("/\(filename)")
                    if !(fileManager.fileExists(atPath: fileSavedPath)) {
                        downloadList.append(FileDownload(fileName: filename, fileURL: fileURL!))
                        ctrfiles += 1
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
            do {
                let result = try dbManager.database.executeQuery("Select hf.filename from activityfiles as hf where  hf.active = 1 order by hf.sort asc", values: nil)
                while result.next() {
                    
                    filename = result.string(forColumn: "filename")
                    let fileURL = URL(string: Vars.baseURL.appending("files/\(filename)"))
                    
                    var fileSavedPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    fileSavedPath = fileSavedPath.appending("/\(filename)")
                    if !(fileManager.fileExists(atPath: fileSavedPath)) {
                        downloadList.append(FileDownload(fileName: filename, fileURL: fileURL!))
                        ctrfiles += 1
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
            do {
                let result = try dbManager.database.executeQuery("Select hf.filename from pagefiles as hf inner join page as f on hf.pageid = f.pageid where  hf.active = 1 and f.active = 1 order by hf.sort asc", values: nil)
                while result.next() {
                    
                    filename = result.string(forColumn: "filename")
                    let fileURL = URL(string: Vars.baseURL.appending("files/\(filename)"))
                    
                    var fileSavedPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    fileSavedPath = fileSavedPath.appending("/\(filename)")
                    if !(fileManager.fileExists(atPath: fileSavedPath)) {
                        downloadList.append(FileDownload(fileName: filename, fileURL: fileURL!))
                        ctrfiles += 1
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
            do {
                let result = try dbManager.database.executeQuery("Select filename from page as f where f.active = 1 order by sort asc", values: nil)
                while result.next() {
                    
                    filename = result.string(forColumn: "filename")
                    let fileURL = URL(string: Vars.baseURL.appending("files/\(filename)"))
                    
                    var fileSavedPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    fileSavedPath = fileSavedPath.appending("/\(filename)")
                    if !(fileManager.fileExists(atPath: fileSavedPath)) {
                        downloadList.append(FileDownload(fileName: filename, fileURL: fileURL!))
                        ctrfiles += 1
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
            do {
                let result = try dbManager.database.executeQuery("Select * from mainfiles as hf where hf.active = 1 order by sort asc", values: nil)
                while result.next() {
                    
                    filename = result.string(forColumn: "filename")
                    let fileURL = URL(string: Vars.baseURL.appending("files/\(filename)"))
                    
                    var fileSavedPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    fileSavedPath = fileSavedPath.appending("/\(filename)")
                    if !(fileManager.fileExists(atPath: fileSavedPath)) {
                        downloadList.append(FileDownload(fileName: filename, fileURL: fileURL!))
                        ctrfiles += 1
                    }
                    
                    filename = result.string(forColumn: "filename2")
                    let fileURL2 = URL(string: Vars.baseURL.appending("files/\(filename)"))

                    var fileSavedPath2 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    fileSavedPath2 = fileSavedPath2.appending("/\(filename)")
                    if !(fileManager.fileExists(atPath: fileSavedPath2)) {
                        downloadList.append(FileDownload(fileName: filename, fileURL: fileURL2!))
                        ctrfiles += 1
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
            do {
                let result = try dbManager.database.executeQuery("Select * from appsectionpage as hf order by sort asc", values: nil)
                while result.next() {
                    
                    filename = result.string(forColumn: "imgfilename")
                    let fileURL = URL(string: Vars.baseURL.appending("files/\(filename)"))
                    
                    var fileSavedPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    fileSavedPath = fileSavedPath.appending("/\(filename)")
                    if !(fileManager.fileExists(atPath: fileSavedPath)) {
                        downloadList.append(FileDownload(fileName: filename, fileURL: fileURL!))
                        ctrfiles += 1
                    }
                    
                    filename = result.string(forColumn: "imgfilename2")
                    let fileURL2 = URL(string: Vars.baseURL.appending("files/\(filename)"))

                    var fileSavedPath2 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    fileSavedPath2 = fileSavedPath2.appending("/\(filename)")
                    if !(fileManager.fileExists(atPath: fileSavedPath2)) {
                        downloadList.append(FileDownload(fileName: filename, fileURL: fileURL2!))
                        ctrfiles += 1
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
            do {
                let result = try dbManager.database.executeQuery("Select filename from appsectionpagelink as f order by sort asc", values: nil)
                while result.next() {
                    
                    filename = result.string(forColumn: "filename")
                    let fileURL = URL(string: Vars.baseURL.appending("files/\(filename)"))
                    
                    var fileSavedPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    fileSavedPath = fileSavedPath.appending("/\(filename)")
                    if !(fileManager.fileExists(atPath: fileSavedPath)) {
                        downloadList.append(FileDownload(fileName: filename, fileURL: fileURL!))
                        ctrfiles += 1
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
            dbManager.database.close()
        }
        
        if ctrfiles > 0 {
            delegate?.completedUpdate(havingFilesToDownload: true, _fileDownloads: downloadList)
            DBManager.shared.executeQuery(query: "Update status set stat = '" + updateStatus + "'")
        }
        else {
            if Vars.transtype == 0 {
                delegate?.completedUpdate(havingFilesToDownload: false, _fileDownloads: downloadList)
            }
            else if Vars.transtype == 2 {
                DBManager.shared.executeQuery(query: "Update hotelfiles set selected = '1' where fileid in ("
                    + Vars.sendEmail + ")")
            }
            Vars.transtype = 0
            DBManager.shared.executeQuery(query: "Update status set stat = '" + updateStatus + "'")
        }
    }
}
