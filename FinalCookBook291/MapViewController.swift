import UIKit
import MapKit
import CoreLocation

struct StoreInfo {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let category: String
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        configureMapView()
    }

    func configureMapView() {
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
        mapView.isUserInteractionEnabled = true
    }
    
    func geocodeAndSearchGroceryStores(zipCode: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(zipCode) { [weak self] (placemarks, error) in
            guard let self = self,
                  let placemark = placemarks?.first,
                  let location = placemark.location else {
                print("No location found for \(zipCode): \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.searchNearbyGroceryStores(location: location)
        }
    }
    
    func searchNearbyGroceryStores(location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "grocery store Walmart | Aldi | Harris Teeter | Kroger"
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 80467, longitudinalMeters: 80467) // 50 miles

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self, let response = response, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let stores = response.mapItems.map {
                StoreInfo(name: $0.name ?? "Unknown", coordinate: $0.placemark.coordinate, category: $0.placemark.title ?? "Grocery Store")
            }
            self.updateMapWithStores(stores: stores)
        }
    }
    
    func updateMapWithStores(stores: [StoreInfo]) {
        mapView.removeAnnotations(mapView.annotations)
        var zoomRect = MKMapRect.null
        for store in stores {
            let annotation = MKPointAnnotation()
            annotation.title = store.name
            annotation.coordinate = store.coordinate
            mapView.addAnnotation(annotation)

            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            zoomRect = zoomRect.union(pointRect)
        }

        let scaledRect = zoomRect.insetBy(dx: -zoomRect.size.width * 0.1, dy: -zoomRect.size.height * 0.1)
        mapView.setVisibleMapRect(scaledRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if let zipCode = zipCodeTextField.text, !zipCode.isEmpty {
            geocodeAndSearchGroceryStores(zipCode: zipCode)
        } else {
            print("Zip code is empty.")
        }
    }
}
