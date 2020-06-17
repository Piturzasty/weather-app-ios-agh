import Foundation

class WeatherDownloader {
    public class func downloadWeather(cityId: Int, completion: @escaping (WeatherInfo?) -> ()) {
        let url = URL(string: "https://www.metaweather.com/api/location/\(cityId)/")!
        
        WeatherDownloader.getData(from: url) { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                let data = data, error == nil,
                let weatherInfo = self.parseWeatherInfo(data: data)
                else { return }
            DispatchQueue.main.async() { [] in
                if let response = response as? HTTPURLResponse, 200 == response.statusCode {
                    completion(weatherInfo)
                }
            }
        }
    }
    
    private class func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession(configuration: .default).dataTask(with: url, completionHandler: completion).resume()
    }
    
    private class func parseWeatherInfo(data: Data) -> WeatherInfo? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WeatherInfo.self, from: data)
        } catch let error {
            print("\(error.localizedDescription)")
            return nil
        }
    }
}
