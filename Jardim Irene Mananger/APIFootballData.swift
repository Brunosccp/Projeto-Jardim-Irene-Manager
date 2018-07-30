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
    func getMatchesOdds() -> [(Int, Double, Double, Double)]{
        var matchesOdds: [(Int, Double, Double, Double)] = []
        
        var idHomeTeam: Int
        var idAwayTeam: Int
        let homeTable = getTable("HOME")
        let awayTable = getTable("AWAY")
        
        
        //variáveis referentes ao todos times do campeonato
        var totalGamesPlayedHome = 0.0
        var totalGamesPlayedAway = 0.0
        var totalGoalsForHome = 0.0   //funciona também como totalGoalsAgainstAway
        var totalGoalsForAway = 0.0   //funciona também como totalGoalsAgainstHome
        
        for i in 0..<homeTable.count{
            totalGamesPlayedHome += homeTable[i]["playedGames"].double!
            totalGamesPlayedAway += awayTable[i]["playedGames"].double!
            
            totalGoalsForHome += homeTable[i]["goalsFor"].double!
            totalGoalsForAway += awayTable[i]["goalsFor"].double!
        }
        //print(totalGamesPlayedHome)
        //print(totalGamesPlayedAway)
        //print(totalGoalsForHome)    //funciona também como totalGoalsAgainstAway
        //print(totalGoalsForAway)    //funciona também como totalGoalsAgainstHome
        
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
            var gamesPlayedHome: Double = -1
            var gamesPlayedAway: Double = -1
            var goalsForHome: Double = -1
            var goalsForAway: Double = -1
            var goalsAgainstHome: Double = -1
            var goalsAgainstAway: Double = -1
            
            //procurando os times que vão jogar pelo ID, e quando acha guarda informacoes nas variáveis
            for j in 0..<homeTable.count{
                if(homeTable[j]["team"]["id"].int == idHomeTeam){
                    //print("mandante: ", homeTable[j]["team"]["name"].string)
                    
                    gamesPlayedHome = homeTable[j]["playedGames"].double!
                    goalsForHome = homeTable[j]["goalsFor"].double!
                    goalsAgainstHome = homeTable[j]["goalsAgainst"].double!
                }
                if(awayTable[j]["team"]["id"].int == idAwayTeam){
                    //print("visitante: ", awayTable[j]["team"]["name"].string)
                    
                    gamesPlayedAway = awayTable[j]["playedGames"].double!
                    goalsForAway = awayTable[j]["goalsFor"].double!
                    goalsAgainstAway = awayTable[j]["goalsAgainst"].double!
                }
                
            }
//            print("""
//                gamesPlayedHome: \(gamesPlayedHome)
//                gamesPlayedAway: \(gamesPlayedAway)
//                goalsForHome: \(goalsForHome)
//                goalsForAway: \(goalsForAway)
//                goalsAgainstHome: \(goalsAgainstHome)
//                goalsAgainstAway: \(goalsAgainstAway)
//            """)
            
            //obtendo a predição de gol dos dois times
            let teamHome = PoissonPrediction(gamesPlayed: gamesPlayedHome, goalsFor: goalsForHome, goalsAgainst: goalsAgainstHome, totalGamesPlayed: totalGamesPlayedHome, totalGoalsFor: totalGoalsForHome, totalGoalsAgainst: totalGoalsForAway)
            let teamAway = PoissonPrediction(gamesPlayed: gamesPlayedAway, goalsFor: goalsForAway, goalsAgainst: goalsAgainstAway, totalGamesPlayed: totalGamesPlayedAway, totalGoalsFor: totalGoalsForAway, totalGoalsAgainst: totalGoalsForHome)
            
            //obtendo o ID da partida
            let matchID = jsonMatches!["matches"][i]["id"].int
            let odds = PoissonPrediction.calculateOdds(teamHome: teamHome, teamAway: teamAway)
            
            matchesOdds.append((matchID!, odds.0, odds.1, odds.2))
            
        }
        
        return matchesOdds
    }
    
    func getTable(_ type: String) -> JSON{
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
    func getMatches() -> JSON{
        return jsonMatches!
    }
}
