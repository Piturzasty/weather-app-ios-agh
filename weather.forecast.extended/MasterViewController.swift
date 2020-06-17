import UIKit

protocol ModalDelegate {
    func saveCity(city: City)
}

class MasterViewController: UITableViewController, ModalDelegate {
    var detailViewController: DetailViewController? = nil
    var cities = [City]()
    
    func saveCity(city: City) {
        cities.append(city)
        tableView.reloadData()
    }
    
    func initialData() -> [City] {
        var cities = [City]()
        
        cities.append(City(id: 44418, name: "London"))
        cities.append(City(id: 1940345, name: "Dubai"))
        cities.append(City(id: 523920, name: "Warsaw"))
        
        return cities
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cities = initialData()
        
        tableView.estimatedRowHeight = 84
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = cities[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.city = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
        else if segue.identifier == "showAdd" {
            let controller = segue.destination as! AddCityViewController
            controller.delegate = self
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Saved cities"
        default:
            return "Unknown"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CityViewCell
        let city = cities[indexPath.row]
        
        WeatherDownloader.downloadWeather(cityId: city.id) { weatherInfo in
            guard let weatherInfo = weatherInfo else { return }
            
            cell.temperature.text = String(format: "%.2f", weatherInfo.getTemp())
            cell.city.text = weatherInfo.getCity()
            
            ImageDownloader.downloadImage(weatherState: weatherInfo.getCurrentWeatherStateAbbr()) { image in
                guard let image = image else { return }
                cell.weatherIcon.image = image
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
}

