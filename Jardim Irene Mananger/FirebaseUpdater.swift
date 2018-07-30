//
//  FirebaseUpdater.swift
//  Jardim Irene Mananger
//
//  Created by Bruno Rocca on 30/07/2018.
//  Copyright © 2018 Bruno Rocca. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON

class FirebaseUpdater{
    var ref: DatabaseReference!
    
    let league: String
    let table: JSON
    let matches: JSON
    
    init(league: String, table: JSON, matches: JSON){
        self.ref = Database.database().reference()
        self.league = league
        self.table = table
        self.matches = matches
    }
    
    func updateTeams(){
        //percorrendo todos os times e jogando no firebase
        for i in 0..<table.count{
            //obtendo informações do JSON
            let teamID = table[i]["team"]["id"].int
            let teamName = table[i]["team"]["name"].string
            let teamPosition = table[i]["position"].int
            let teamPoints = table[i]["points"].int
            let teamGoalDifference = table[i]["goalDifference"].int
            let teamGoalsFor = table[i]["goalsFor"].int
            let teamGoalsAgainst = table[i]["goalsAgainst"].int
            let teamWon = table[i]["won"].int
            let teamLost = table[i]["lost"].int
            let teamDraw = table[i]["draw"].int
            
            
            let teamReference = ref.child(league).child("teams").child("\(teamID!)")
            
            //criando o dado do time
            let newTeamData = [
                "id" : teamID!,
                "name" : teamName!,
                "position" : teamPosition!,
                "points" : teamPoints!,
                "goalDifference" : teamGoalDifference!,
                "goalsFor" : teamGoalsFor!,
                "goalsAgainst" : teamGoalsAgainst!,
                "won" : teamWon!,
                "lost" : teamLost!,
                "draw" : teamDraw!
                ] as [String : Any]
            
            teamReference.setValue(newTeamData)
            
            print("CREATED WITH SUCESSFUL")
        }
    }
    func updateMatches(matchesOdds : [(Int, Double, Double, Double)]){
        
        //percorrendo todas as partidas e jogando no firebase
        for i in 0..<matches["matches"].count{
            //obtendo as informações da partida
            let id = matches["matches"][i]["id"].int!
            let homeTeamID = matches["matches"][i]["homeTeam"]["id"].int!
            let awayTeamID = matches["matches"][i]["awayTeam"]["id"].int!
            
            //print("id: \(id!), home: \(homeTeamID!), away: \(awayTeamID!)")
            
            //variáveis das odds
            var homeWinOdd = 0.0
            var awayWinOdd = 0.0
            var drawOdd = 0.0
            
            //percorrendo todas as odds para achar a odd da partida em questão
            for j in 0..<matchesOdds.count{
                if(id == matchesOdds[j].0){
                    homeWinOdd = matchesOdds[j].1
                    awayWinOdd = matchesOdds[j].2
                    drawOdd = matchesOdds[j].3
                    
                    break
                }
            }
            //criando referência de childs
            let matchReference = ref.child(league).child("matches").child("\(id)")
            
            let newMatchData = [
                "id" : id,
                "homeTeamID" : homeTeamID,
                "awayTeamID" : awayTeamID,
                "homeWinOdd" : homeWinOdd,
                "awayWinOdd" : awayWinOdd,
                "drawOdd" : drawOdd
                ] as [String : Any]
            
            matchReference.setValue(newMatchData)
            
            print("match data created with sucessful")
        }
        
    }
    
    
}
