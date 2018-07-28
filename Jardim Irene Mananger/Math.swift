//
//  Math.swift
//  Jardim Irene Mananger
//
//  Created by Bruno Rocca on 28/07/2018.
//  Copyright © 2018 Bruno Rocca. All rights reserved.
//

import Foundation

class Math{
    static func factorial(_ x: Int) -> Int{
        var result = 1
        
        if(x <= 1){
            return result
        }
        
        for i in 2...x{
            result *= i
        }
        return result
    }
    static func poisson(events: Double, average: Double) -> Double{
        let e = M_E
        
        let result = (pow(e, -average) * pow(average, events)) / Double(Math.factorial(Int(events)))
        
        return result
    }
}
