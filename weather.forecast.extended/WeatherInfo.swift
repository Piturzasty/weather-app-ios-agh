import Foundation

extension Float {
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}

struct WeatherInfo: Codable {
    struct WeatherDay: Codable {
        let weatherStateAbbr: String
        let applicableDate: String
        let theTemp: Float
        let minTemp: Float
        let maxTemp: Float
        let windSpeed: Float
        let windDirectionCompass: String
        let humidity: Int
        let airPressure: Float
        let weatherStateName: String
    }
    
    let consolidatedWeather: [WeatherDay]
    let title: String
    let lattLong: String
    
    func getTemp() -> Float {
        return consolidatedWeather[0].theTemp.rounded(toPlaces: 2)
    }
    
    func getMinTemp(currentDay: Int) -> Float {
        return consolidatedWeather[currentDay].minTemp.rounded(toPlaces: 2)
    }
    
    func getMaxTemp(currentDay: Int) -> Float {
        return consolidatedWeather[currentDay].maxTemp.rounded(toPlaces: 2)
    }
    
    func getWindSpeed(currentDay: Int) -> Float {
        return consolidatedWeather[currentDay].windSpeed.rounded(toPlaces: 2)
    }
    
    func getWindDirection(currentDay: Int) -> String {
        return consolidatedWeather[currentDay].windDirectionCompass
    }
    
    func getHumidity(currentDay: Int) -> Int {
        return consolidatedWeather[currentDay].humidity
    }
    
    func getAirPressure(currentDay: Int) -> Float {
        return consolidatedWeather[currentDay].airPressure.rounded(toPlaces: 2)
    }
    
    func getCurrentDate(currentDay: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd"
        let date: Date = dateFormatter.date(from: consolidatedWeather[currentDay].applicableDate)!
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
    
    func getCurrentWeatherStateAbbr() -> String {
        return consolidatedWeather[0].weatherStateAbbr
    }
    
    func getWeatherState(currentDay: Int) -> String {
        return consolidatedWeather[currentDay].weatherStateName
    }
    
    func getWeatherStateAbbr(currentDay: Int) -> String {
        return consolidatedWeather[currentDay].weatherStateAbbr
    }
    
    func getCity() -> String {
        return title
    }
    
    func getCoordinates() -> String {
        return lattLong
    }
}
