//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate{
    func didUpdatePrice(price : String, currency : String)
    func didFailWithError(error : Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "C3AF6766-E49E-4A23-AF17-13B7D33B6584"
    
    let currencyArray = ["Select Currency","AUD", "JPY","USD","CNY","EUR","GBP","HKD","IDR","ILS","INR","BRL","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","CAD","ZAR"]

    func getCoinPrice(for currency : String){
        
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        //print(urlString)
        
        //Use optional binding to unwrap the URL that's created the urlString
        if let url = URL(string: urlString){
            
            
            //Create a new URLSession object with default configuration
            let session = URLSession(configuration: .default)
            
            //Create a new data task for the URLSession
            let task = session.dataTask(with : url){ (data, response, error) in
                if error != nil {
                    //print(error)
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                //format the data we got back as a string to be able to print it
                //let dataAsString = String(data: data!, encoding: .utf8)
                //print(dataAsString)
                if let safeData = data {
                    if let bitecoinPrice = self.parseJSON(safeData){
                        //Optional : round the price down to 2 decimal places
                        let priceString = String(format: "%.2f", bitecoinPrice)
                        
                        //press along the necessary data
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
            }
            //Start task to fetch data from bitcoin average's servers
            task.resume()
        }
    }
    
    func parseJSON(_ data : Data) -> Double?{
        //Create a JSONDEcoder
        let decoder = JSONDecoder()
        
        do{
            //try to decode the data using the CoinData structure
            let decodeData = try decoder.decode(CoinData.self, from: data)
            
            //Get the last property from the decoded data
            let lastPrice = decodeData.rate
            print(lastPrice)
            return lastPrice
        }catch{
            print(error)
            return nil
        }
    }
    
}


