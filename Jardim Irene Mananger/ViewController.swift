//
//  ViewController.swift
//  Jardim Irene Mananger
//
//  Created by Bruno Rocca on 26/07/2018.
//  Copyright © 2018 Bruno Rocca. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("vem papai")
        //loadStarWarsPeopleData()
        //loadData()
        loadBrasileiro()
        
        let teamHome = PoissonPrediction(gamesPlayed: 19, goalsFor: 36, goalsAgainst: 11, totalGamesPlayed: 380, totalGoalsFor: 598, totalGoalsAgainst: 454)
        let teamAway = PoissonPrediction(gamesPlayed: 19, goalsFor: 17, goalsAgainst: 32, totalGamesPlayed: 380, totalGoalsFor: 454, totalGoalsAgainst: 598)
        
        PoissonPrediction.calculateOdds(teamHome: teamHome, teamAway: teamAway)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadData(){
        let urlString = "http://api.football-data.org/v2/competitions"
        //making request
        Alamofire.request(urlString).responseData { (dataResponse) in
            //getting data
            if let data = dataResponse.result.value {
                do{
                    let json = try JSON(data: data)
                    print(json["competitions"].array![19])
                }catch{
                    print("ERROR: converting data to JSON")
                }
            }
        }
    }
    func loadBrasileiro(){
        let urlString = "http://api.football-data.org/v2/competitions/2013"
        
        let headers: HTTPHeaders = ["X-Auth-Token" : "c4b18bd19f5941cea8f25182a7a79b06"]
        
        var currentMatchDay: Int?
        
        
        //criando uma fila para sincronização
        DispatchQueue.global(qos: .userInitiated).async {
            //criando grupo para sincronizar
            let group = DispatchGroup()
            group.enter()
            
            //fazendo o request
            print("start of request")
            Alamofire.request(urlString, headers: headers).responseData { (dataResponse) in
                //getting data
                
                if let data = dataResponse.result.value {
                    do{
                        let json = try JSON(data: data)
                        currentMatchDay = json["currentSeason"]["currentMatchday"].int
                        
                        print("ERROR: ",json["message"])
                        
                        group.leave()
                        print("end of request")
                    }catch{
                        print("ERROR: converting data to JSON")
                    }
                }
            }
            //esperando o final do request
            group.wait()
            
            print("Printing values in variables:")
            print(currentMatchDay!)
            
        }
        
        
    }
    
    
    func loadStarWarsPeopleData() {
        let urlString = "http://swapi.co/api/people/"
        //making request
        Alamofire.request(urlString).responseData { (dataResponse) in
            //getting data
            if let data = dataResponse.result.value {
                do{
                    let json = try JSON(data: data)
                    print(json["results"].array![0]["name"])
                }catch{
                    print("ERROR: converting data to JSON")
                }
            }
        }
    }
    
}

