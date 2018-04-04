//
//  DBManager.swift
//  RHGSA
//
//  Created by Mohamed Anas on 3/29/18.
//  Copyright © 2018 Mohamed Anas. All rights reserved.
//

import UIKit

class DBManager: NSObject {
    
    static let shared: DBManager = DBManager()
    let databaseFileName = "rhgsa.db"
    var pathToDatabase: String!    
    var database: FMDatabase!

    var fetchResult: NSArray = []
    
    // MARK: - Init Method
    override init() {
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
        pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
    }
    
    // MARK: - Open DB
    func openDatabase() -> Bool {
        if database == nil {
            if FileManager.default.fileExists(atPath: pathToDatabase) {
                database = FMDatabase(path: pathToDatabase)
            }
            else {
                let resourcePath = Bundle.main.path(forResource: "rhgsa", ofType: ".db")
                do {
                    try FileManager.default.copyItem(atPath: resourcePath!, toPath: pathToDatabase)
                }
                catch {
                    print("Error while copying file")
                    return false
                }
                database = FMDatabase(path: pathToDatabase)
            }
        }
        if database != nil {
            if database.open() {
                return true
            }
        }
        return false
    }
    
    // MARK: - SQLite Operation
    func runQurey(query: String) -> FMResultSet {
        var result = FMResultSet()
        if openDatabase() {
            do {
                let fmResult = try database.executeQuery(query, values: nil)
                result = fmResult
                while fmResult.next(){
                    let url = fmResult.string(forColumn: "url")
                    print(url)
                }
            } catch {
                print(error.localizedDescription)
            }
            database.close()
        }
        return result
    }
    func executeQuery(query: String) {
        if openDatabase() {
            if !database.executeStatements(query) {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
            database.close()
        }
    }
}
