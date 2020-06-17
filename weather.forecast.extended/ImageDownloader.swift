import UIKit
import Foundation

class ImageDownloader {
    public class func downloadImage(weatherState: String, completion: @escaping (UIImage?) -> ()) {
        let url = URL(string: "https://www.metaweather.com/static/img/weather/png/\(weatherState).png")!
        
        ImageDownloader.getData(from: url) { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [] in
                completion(image)
            }
        }
    }
    
    private class func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession(configuration: .default).dataTask(with: url, completionHandler: completion).resume()
    }
}
