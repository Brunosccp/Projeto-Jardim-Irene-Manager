//
//  PoissonPrediction.swift
//  Jardim Irene Mananger
//
//  Created by Bruno Rocca on 28/07/2018.
//  Copyright © 2018 Bruno Rocca. All rights reserved.
//

import Foundation

class PoissonPrediction{
    //apenas o time
    let averageGoalsFor: Double
    let averageGoalsAgainst: Double
    
    //o campeonato todo
    let totalAverageGoalsFor: Double
    let totalAverageGoalsAgainst: Double
    
    init(gamesPlayed: Double, goalsFor: Double, goalsAgainst: Double, totalGamesPlayed: Double, totalGoalsFor: Double, totalGoalsAgainst: Double){
        //apenas o time
        self.averageGoalsFor = goalsFor / gamesPlayed
        self.averageGoalsAgainst = goalsAgainst / gamesPlayed
        
        //o campeonato todo
        self.totalAverageGoalsFor = totalGoalsFor / totalGamesPlayed
        self.totalAverageGoalsAgainst = totalGoalsAgainst / totalGamesPlayed
    }
    
    func getAttackingStrenght() -> Double{
        let attackingStrenght: Double
        attackingStrenght = averageGoalsFor / totalAverageGoalsFor
        
        return attackingStrenght
    }
    func getDefensiveStrenght() -> Double{
        let defensiveStrenght: Double
        defensiveStrenght = averageGoalsAgainst / totalAverageGoalsAgainst
        
        return defensiveStrenght
    }
    
    static func homeTeamGoalExpenctancy(teamHome: PoissonPrediction, teamAway: PoissonPrediction) -> Double{
        let homeTeamGoalExpenctancy: Double
        
        homeTeamGoalExpenctancy = teamHome.getAttackingStrenght() * teamAway.getDefensiveStrenght() * teamHome.totalAverageGoalsFor
        
        return homeTeamGoalExpenctancy
    }
    static func awayTeamGoalExpectancy(teamHome: PoissonPrediction, teamAway: PoissonPrediction) -> Double{
        let awayTeamGoalExpenctancy: Double
        
        awayTeamGoalExpenctancy = teamAway.getAttackingStrenght() * teamHome.getDefensiveStrenght() * teamAway.totalAverageGoalsFor
        
        return awayTeamGoalExpenctancy
    }
    
    static func calculateOdds(teamHome: PoissonPrediction, teamAway: PoissonPrediction){
        var oddHomeWin = 0.0
        var oddAwayWin = 0.0
        var oddDraw = 0.0
        
        for i in 0...10{
            for j in 0...10{
                if(i>j){    //se o time da casa fazer mais gols do que o visitante (time da casa ganhar)
                    oddHomeWin += Math.poisson(events: Double(i), average: homeTeamGoalExpenctancy(teamHome: teamHome, teamAway: teamAway)) * Math.poisson(events: Double(j), average: awayTeamGoalExpectancy(teamHome: teamHome, teamAway: teamAway))
                }
                else if(j>i){    //se o time visitante fazer mais gols do que o da casa (time visitante ganhar)
                    oddAwayWin += Math.poisson(events: Double(i), average: homeTeamGoalExpenctancy(teamHome: teamHome, teamAway: teamAway)) * Math.poisson(events: Double(j), average: awayTeamGoalExpectancy(teamHome: teamHome, teamAway: teamAway))
                }
                else{   //se os dois times fizerem número iguais de gol (empate)
                    oddDraw += Math.poisson(events: Double(i), average: homeTeamGoalExpenctancy(teamHome: teamHome, teamAway: teamAway)) * Math.poisson(events: Double(j), average: awayTeamGoalExpectancy(teamHome: teamHome, teamAway: teamAway))
                }
            }
        }
        
        print("""
            vitória da casa: \(oddHomeWin)
            vitória visitante: \(oddAwayWin)
            empate: \(oddDraw)
            """)
    }
}
