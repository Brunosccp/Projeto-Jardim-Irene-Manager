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
    
        //loadData()
        
        let brazilSerieA = APIFootballData()
        DispatchQueue.global(qos: .userInitiated).async {
            //criando grupo para sincronizar
            let group = DispatchGroup()
            
            group.enter()
            brazilSerieA.makeRequest(urlString: "http://api.football-data.org/v2/competitions/2013", group)
            group.wait()
            
            
            
            let matchesOdds = brazilSerieA.getMatchesOdds()
            
            let updater = FirebaseUpdater(league: "BrazilSerieA", table: brazilSerieA.getTable("TOTAL"), matches: brazilSerieA.getMatches())
            
            updater.updateTeams()
            updater.updateMatches(matchesOdds: matchesOdds)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

