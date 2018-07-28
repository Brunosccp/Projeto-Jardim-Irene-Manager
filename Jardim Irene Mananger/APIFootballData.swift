//
//  ApiManager.swift
//  Jardim Irene Mananger
//
//  Created by Bruno Rocca on 28/07/2018.
//  Copyright © 2018 Bruno Rocca. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class APIFootballData{
    var json: JSON? = nil
    var jsonMatches: JSON? = nil
    
    func makeRequest(urlString: String,_ group: DispatchGroup){
        let headers: HTTPHeaders = ["X-Auth-Token" : "c4b18bd19f5941cea8f25182a7a79b06"]
        
        let urlStandings = urlString + "/standings"
        //fazendo o request de standings
        print("start of request standings")
        Alamofire.request(urlStandings, headers: headers).responseData { (dataResponse) in
            //getting data
            if let data = dataResponse.result.value {
                do{
                    self.json = try JSON(data: data)
                    print("ERROR: ", self.json!["message"])
                    group.leave()
                    print("end of request standings")
                }catch{
                    print("ERROR: converting data to JSON")
                }
            }
        }
        group.wait()
        group.enter()
        
        //obtendo
        
        let urlMatches = urlString + "/matches"
        //fazendo o request de matches
        print("start of request matches")
        Alamofire.request(urlMatches, headers: headers).responseData { (dataResponse) in
            //getting data
            if let data = dataResponse.result.value {
                do{
                    self.jsonMatches = try JSON(data: data)
                    print("ERROR: ", self.json!["message"])
                    group.leave()
                    print("end of request matches")
                }catch{
                    print("ERROR: converting data to JSON")
                }
            }
        }
        

    }
    func getOdds(){
        //print(json)
        //print(json!["standings"][0]["type"].string!)
        print(getTable("HOME"))
        //print(jsonMatches)
        
    }
    private func getTable(_ type: String) -> JSON{
        var rightTable: Int = -1
        for i in 0...2{ //sempre haverá somente 3 tipos de tabela, tabela total, de mandantes e visitantes
            if(json!["standings"][i]["type"].string! == type){
                rightTable = i
                break
            }
        }
        //print("tabela certa: ", rightTable)
        return json!["standings"][rightTable]["table"][1]
    }
}
