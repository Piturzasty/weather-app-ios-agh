import UIKit
import CoreLocation

class CitySearch: Codable {
    let woeid: Int
    let title: String
}

class AddCityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var cityQuery: UITextField!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var delegate: ModalDelegate?
    
    var locationCity = [CitySearch]()
    var cities = [CitySearch]()
    
    var locationManager = CLLocationManager()
    
    @IBAction func onChange(_ sender: UIButton) {
        if cityQuery.text! == "" || cityQuery?.text == nil {
            return
        }
        
        let url = URL(string: "https://www.metaweather.com/api/location/search/?query=\(cityQuery.text!)")!
        
        let task = URLSession(configuration: .default).dataTask(with: url) { data, response, error in
            guard
                let data = data, error == nil else { return }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let cities = try! decoder.decode([CitySearch].self, from: data)
            
            DispatchQueue.main.async() { [weak self] in
                self?.cities = cities
                self?.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        getUserLocation()
    }
    
    private func getUserLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled() {
            return
        }
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.requestLocation()
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Current Location"
        case 1:
            return "From query"
        default:
            return "Unknown"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return locationCity.count
        } else if section == 1 {
            return cities.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel!.text = locationCity[0].title
        } else if indexPath.section == 1 {
            let city = cities[indexPath.row]
            cell.textLabel!.text = city.title
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let city = locationCity[indexPath.row]
            delegate?.saveCity(city: City(id: city.woeid, name: city.title))
        }
        else if indexPath.section == 1 {
            let city = cities[indexPath.row]
            delegate?.saveCity(city: City(id: city.woeid, name: city.title))
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension AddCityViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager authorization status changed")
        switch status {
        case .authorizedAlways:
            locationManager.requestLocation()
            break
        case .authorizedWhenInUse:
            locationManager.requestLocation()
            break
        case .denied:
            break
        case .restricted:
            break
        case .notDetermined:
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let lattitude: Double = location!.coordinate.latitude
        let longitude: Double = location!.coordinate.longitude
        let url = URL(string: String(format: "https://www.metaweather.com/api/location/search/?lattlong=%.3f,%.3f", lattitude, longitude))!
        
        let task = URLSession(configuration: .default).dataTask(with: url) { data, response, error in
            guard
                let data = data, error == nil else { return }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let cities = try! decoder.decode([CitySearch].self, from: data)
            
            DispatchQueue.main.async() { [weak self] in
                self?.locationCity = [cities[0]]
                self?.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
