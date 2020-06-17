import UIKit
import CoreLocation

class DetailViewController: UIViewController {
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    @IBOutlet weak var minTemp: UITextField!
    @IBOutlet weak var maxTemp: UITextField!
    @IBOutlet weak var windSpeed: UITextField!
    @IBOutlet weak var windDirection: UITextField!
    @IBOutlet weak var humidity: UITextField!
    @IBOutlet weak var airPressure: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var weatherState: UILabel!
    @IBOutlet weak var currentDate: UILabel!
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        if (Int(sender.value) > currentDay) {
            currentDay = currentDay + 1
        } else {
            currentDay = currentDay - 1
        }
        getCurrentWeather()
    }
    
    var currentDay: Int = 0
    var weatherInfo: WeatherInfo? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapButton.isEnabled = false
        configureView()
    }
    
    var city: City? {
        didSet {
            configureView()
        }
    }
    
    private func configureView() {
        guard
            let city = city,
            let navBar = navBar
            else { return }
        navBar.title = city.name
        getCurrentWeather()
    }
    
    private func getCurrentWeather() {
        guard
            let city = city else { return }
        if weatherInfo != nil && weatherInfo!.consolidatedWeather.count == 6 {
            setData()
            return
        }
        
        WeatherDownloader.downloadWeather(cityId: city.id) { weatherInfo in
            guard
                let weatherInfo = weatherInfo
                else { return }
            self.navBar.title = weatherInfo.getCity()
            self.mapButton.isEnabled = true
            self.weatherInfo = weatherInfo
            self.setData()
        }
    }

    private func setData() {
        ImageDownloader.downloadImage(weatherState: (weatherInfo?.getWeatherStateAbbr(currentDay: self.currentDay))!) { image in
            guard let image = image else { return }
            self.image.image = image
        }
        
        self.minTemp.text = String(format: "%.2f", weatherInfo!.getMinTemp(currentDay: self.currentDay))
        self.maxTemp.text = String(format: "%.2f", weatherInfo!.getMaxTemp(currentDay: self.currentDay))
        self.windSpeed.text = String(format: "%.2f", weatherInfo!.getWindSpeed(currentDay: self.currentDay))
        self.windDirection.text = "\(weatherInfo!.getWindDirection(currentDay: self.currentDay))"
        self.humidity.text = String(format: "%i%%", weatherInfo!.getHumidity(currentDay: self.currentDay))
        self.airPressure.text = String(format: "%.2f", weatherInfo!.getAirPressure(currentDay: self.currentDay))
        self.weatherState.text = "\(weatherInfo!.getWeatherState(currentDay: self.currentDay))"
        self.currentDate.text = "\(weatherInfo!.getCurrentDate(currentDay: self.currentDay))"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let controller = segue.destination as! MapViewController
            let lattLongString = weatherInfo!.getCoordinates()
            let latt = Double(lattLongString.components(separatedBy: ",")[0])
            let long = Double(lattLongString.components(separatedBy: ",")[1])
            controller.locationName = weatherInfo!.getCity()
            controller.centerLocation = CLLocation(latitude: latt!, longitude: long!)
        }
    }
}
