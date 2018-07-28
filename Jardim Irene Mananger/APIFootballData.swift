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
        
        //fazendo url da tabela do campeonato
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
        
        //obtendo a próxima rodada
        let matchday = json!["season"]["currentMatchday"].int!
        
        //fazendo url de todos os jogos do campeonato
        let urlMatches = urlString + "/matches?matchday=\(matchday)"
        //fazendo o request de matches da rodada atual
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
        var idHomeTeam: Int
        var idAwayTeam: Int
        let homeTable = getTable("HOME")
        let awayTable = getTable("AWAY")
        
        for i in 0..<jsonMatches!["matches"].count{
            //print(jsonMatches!["matches"][i]["homeTeam"]["name"])
            //print(jsonMatches!["matches"][i]["awayTeam"]["name"])
            
            //pegando o ID dos clubes que vão jogar
            idHomeTeam = jsonMatches!["matches"][i]["homeTeam"]["id"].int!
            idAwayTeam = jsonMatches!["matches"][i]["awayTeam"]["id"].int!
            
            //consertando cagada da API
            if(idHomeTeam == 1839){
                idHomeTeam = 6684
            }
            
            //pegando informação dos clubes
            
            //variáveis referentes ao time
            var gamesPlayedHome: Int
            var gamesPlayedAway: Int
            var goalsForHome: Int
            var goalsForAway: Int
            var goalsAgainstHome: Int
            var goalsAgainstAway: Int
            
            //variáveis referentes ao todos times do campeonato
            var totalGamesPlayedHome: Int
            var totalGamesPlayedAway: Int
            var totalGoalsForHome: Int
            var totalGoalsForAway: Int
            var totalGoalsAgainstHome: Int
            var totalGoalAgainstAway: Int
            
            //procurando os times que vão jogar pelo ID, e quando acha guarda informacoes nas variáveis
            for j in 0..<homeTable.count{
                if(homeTable[j]["team"]["id"].int == idHomeTeam){
                    print("mandante: ", homeTable[j]["team"]["name"].string)
                    
                    
                }
                if(awayTable[j]["team"]["id"].int == idAwayTeam){
                    print("visitante: ", awayTable[j]["team"]["name"].string)
                    
                    
                }
                
                
            }
            
            let teamHome = PoissonPrediction(gamesPlayed: 19, goalsFor: 36, goalsAgainst: 11, totalGamesPlayed: 380, totalGoalsFor: 598, totalGoalsAgainst: 454)
            let teamAway = PoissonPrediction(gamesPlayed: 19, goalsFor: 17, goalsAgainst: 32, totalGamesPlayed: 380, totalGoalsFor: 454, totalGoalsAgainst: 598)
            
            //PoissonPrediction.calculateOdds(teamHome: teamHome, teamAway: teamAway)
            
            //print(idHomeTeam)
            //print(idAwayTeam)
            
        }
        //print(homeTable)
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
        return json!["standings"][rightTable]["table"]
    }
}
