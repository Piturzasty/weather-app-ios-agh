import UIKit
import CoreLocation
import MapKit

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 10000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

private class MapMarker: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
   }
}

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            updateMapLocation()
        }
    }
    var centerLocation: CLLocation? {
        didSet {
            updateMapLocation()
        }
    }
    var locationName: String? = nil
    
    @IBAction func onExit(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func updateMapLocation() {
        guard
            let map = mapView,
            let location = centerLocation else { return }
        map.centerToLocation(location)
        let pin = MapMarker(title: locationName!, coordinate: location.coordinate)
        map.addAnnotation(pin)
    }
}
