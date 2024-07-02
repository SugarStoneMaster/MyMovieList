//
//  TroupeAPI.swift
//  MyMovieList
//
//  Created by Carmine Iemmino on 17/06/24.
//

import Foundation


class TroupeViewModel: ObservableObject
{
    var urlSub: String = "troupe/"
    
    @Published var singleTroupe: Troupe? = nil
    @Published var successMessage: String?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    
    func getTroupe(troupeId: String)
    {
        guard let url = URL(string: baseUrl + urlSub + "get_troupe/\(troupeId)") else {
            print("Invalid URL")
            return
        }
        
        print(url)
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let singleTroupe = try JSONDecoder().decode(Troupe.self, from: data)
                    DispatchQueue.main.async {
                        self.singleTroupe = singleTroupe
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else if let error = error {
                print("HTTP request failed: \(error)")
            }
        }.resume()
    }
    
    
}
