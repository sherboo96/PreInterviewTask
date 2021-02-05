//
//  ViewController.swift
//  PreInterviewTask
//
//  Created by Sherbeny on 03/02/2021.
//

import UIKit
import MapKit
import Presentr
import Firebase

struct Place {
  let id: String
  let description: String
}

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    //MARK: - IBOutlet
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            self.mapView.delegate = self
        }
    }
    @IBOutlet weak var viewContainerHumbMenu: UIView! {
        didSet {
            viewContainerHumbMenu.layer.cornerRadius = viewContainerHumbMenu.frame.height / 2
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.isHidden = true
            tableView.tableFooterView = UIView()
        }
    }
    @IBOutlet weak var txtCurrentLocation: UITextField!
    @IBOutlet weak var txtDestination: UITextField!
    @IBOutlet weak var viewContainerTopConstrain: NSLayoutConstraint!
    
    //MARK: - Variable
    private let locationManager = CLLocationManager()
    private var arrLocationName = [PlaceModel]()
    private var arrFilter = [PlaceModel]()
    private var matchingItems: [MKMapItem] = []
    private var selectedLocation: MKMapItem?
    private var isMap: Bool = false
    private var places = [Place]()
    private let regionRadius: CLLocationDistance = 1000
    private let longDriverDistance: Double = 10000
    private var placeListener: ListenerRegistration!
    private var nerestDeriver = [PlaceModel]()
    private var arrDeriver = [PlaceModel]()
    
    //MARK: - VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getSourceFirestoreData()
        self.getDeriverFirestoreData()
    }

    //MARK: - Helper Function
    func setupUI() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        configureAuthorizationServices()
        centerMapOnCurrentLocation()
        addDoubleTap()
        
        self.txtCurrentLocation.delegate = self
        self.txtDestination.delegate = self
        
        let nib = UINib(nibName: SideMenuTCell.identifier, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: SideMenuTCell.identifier)
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        for item in arrLocationName {
            if item.name.lowercased().contains(searchText.lowercased()) {
                self.arrFilter.append(item)
            }
        }
        self.isMap = false
        self.tableView.reloadData()
    }
    
    func filterMapForSearch() {
        guard let mapView = mapView,
              let searchBarText = self.txtDestination.text else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.isMap = true
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
            let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
            let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
            return from.distance(from: to)
        }
    
    //MARK: - IBAction
    @IBAction func humbMenuTappedBtn(_ sender: UIButton) {
        let presenter = Presentr(presentationType: .fullScreen)
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "SideMenuVC") as! SideMenuVC
        customPresentViewController(presenter, viewController: VC, animated: true)
    }
    
    @IBAction func requestTappedBtn(_ sender: UIButton) {
        guard let cordinate = locationManager.location?.coordinate else { return }
        for item in self.arrDeriver {
            if self.getDistance(from: cordinate, to: CLLocationCoordinate2DMake(item.latitude, item.longitude)) <= longDriverDistance {
                self.nerestDeriver.append(item)
                let alert = UIAlertController(title: "Alert", message: "\(item.name)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        //TODO: - add any driver
//        guard let selectedLocation = self.selectedLocation else { return }
//
//        Firestore.firestore().collection("Drivers").addDocument(data: [
//            "name": selectedLocation.placemark.title ?? "",
//            "latitude": selectedLocation.placemark.coordinate.latitude,
//            "longitude": selectedLocation.placemark.coordinate.longitude
//        ]) { (error) in
//            if error != nil {
//                print("error")
//            } else {
//
//            }
//        }
    }
}

extension MapVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.arrFilter.removeAll()
        if self.txtCurrentLocation.text != "" && self.txtCurrentLocation.isFirstResponder {
            UIView.animate(withDuration: 0.5) {
                self.viewContainerTopConstrain.constant = 20
                self.view.layoutIfNeeded()
            }
            self.filterContentForSearchText(self.txtCurrentLocation.text ?? "")
        } else if self.txtDestination.text != "" && self.txtDestination.isFirstResponder {
            UIView.animate(withDuration: 0.5) {
                self.viewContainerTopConstrain.constant = 20
                self.view.layoutIfNeeded()
            }
            self.filterMapForSearch()
            self.filterContentForSearchText(self.txtDestination.text ?? "")
        } else {
            UIView.animate(withDuration: 0.5) {
                self.viewContainerTopConstrain.constant = 100
                self.view.layoutIfNeeded()
            }
            self.isMap = false
            self.matchingItems.removeAll()
            self.arrFilter.removeAll()
        }
        self.tableView.isHidden = self.arrFilter.count > 0 || self.matchingItems.count > 0 ? false : true
    }
}

extension MapVC: MKMapViewDelegate, CLLocationManagerDelegate {
    func configureAuthorizationServices() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        } else {
            return
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        centerMapOnCurrentLocation()
    }
    
    func centerMapOnCurrentLocation() {
        guard let cordinate = locationManager.location?.coordinate else { return }
        let cordinatorRegion = MKCoordinateRegion(center: cordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(cordinatorRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var circleRenderer = MKCircleRenderer()
        if let overlay = overlay as? MKCircle {
            circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
            circleRenderer.alpha = 0.5
        }
        return circleRenderer
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removeOldPins()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinator = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let anotation = DropablePin(coordinate: touchCoordinator, identifier: "dropPin")
        mapView.addAnnotation(anotation)
        
        let coordinatorRegion = MKCoordinateRegion(center: touchCoordinator, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinatorRegion, animated: true)
    }
    
    func putPin(cordinate: CLLocationCoordinate2D) {
        let anotation = DropablePin(coordinate: cordinate, identifier: "dropPin")
        mapView.addAnnotation(anotation)
        let coordinatorRegion = MKCoordinateRegion(center: cordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinatorRegion, animated: true)
    }
    
    func removeOldPins() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "dropPin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
}

extension MapVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isMap {
            return matchingItems.count
        }
        return arrFilter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTCell.identifier, for: indexPath) as? SideMenuTCell else {
            return UITableViewCell()
        }
        if isMap {
            cell.lblTitle.text = matchingItems[indexPath.row].placemark.title
        } else {
            cell.lblTitle.text = arrFilter[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: -
        tableView.deselectRow(at: indexPath, animated: true)
        if isMap {
            self.selectedLocation = matchingItems[indexPath.row]
            guard let selectedLocation = self.selectedLocation else { return }
            self.txtDestination.text = selectedLocation.placemark.title
            self.putPin(cordinate: selectedLocation.placemark.coordinate)
        } else {
            self.txtCurrentLocation.text = arrFilter[indexPath.row].name
            self.putPin(cordinate: CLLocationCoordinate2D(latitude: arrFilter[indexPath.row].latitude, longitude: arrFilter[indexPath.row].longitude))
        }
        self.tableView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

//MARK: - Get Firestore data
extension MapVC {
    func getSourceFirestoreData() {
        placeListener = Firestore.firestore().collection("Source")
            .addSnapshotListener { (dataSet, error) in
                if error != nil {
                    print("error")
                } else {
                    self.arrLocationName.removeAll()
                    self.arrLocationName = PlaceModel.parseData(dataSet: dataSet)
                }
            }
    }
    
    func getDeriverFirestoreData() {
        placeListener = Firestore.firestore().collection("Drivers")
            .addSnapshotListener { (dataSet, error) in
                if error != nil {
                    print("error")
                } else {
                    self.arrDeriver.removeAll()
                    self.arrDeriver = PlaceModel.parseData(dataSet: dataSet)
                }
            }
    }
}
