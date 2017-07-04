/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
  
  @IBOutlet weak var sourceField: UITextField!
  @IBOutlet weak var destinationField1: UITextField!
  @IBOutlet weak var destinationField2: UITextField!
  @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
  @IBOutlet var enterButtonArray: [UIButton]!
  
  var originalTopMargin: CGFloat!
  let locationManager = CLLocationManager()
    var locationTuples: [(textField: UITextField?, mapItem: MKMapItem?)]!
    
    var locationsArray: [(textField: UITextField?, mapItem: MKMapItem?)] {
        var filtered = locationTuples.filter({ $0.mapItem != nil })
        filtered += [filtered.first!]
        return filtered
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationTuples = [(sourceField, nil), (destinationField1, nil), (destinationField2, nil)]
    originalTopMargin = topMarginConstraint.constant
    
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestLocation()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = true
  }
  
  @IBAction func getDirections(_ sender: AnyObject) {
    view.endEditing(true)
    performSegue(withIdentifier: "show_directions", sender: self)
  }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if locationTuples[0].mapItem == nil || (locationTuples[1].mapItem == nil && locationTuples[2].mapItem == nil) {
            showAlert("Please enter a valid starting point and at least one destination")
            return false
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let directionsViewController = segue.destination as! DirectionsViewController
        directionsViewController.locationArray = locationsArray
    }

  @IBAction func addressEntered(_ sender: UIButton) {
    view.endEditing(true)
    let currentTextField = locationTuples[sender.tag-1].textField
    CLGeocoder().geocodeAddressString((currentTextField?.text!)!, completionHandler: {(placemarks, error) -> Void in
        if let placemarks = placemarks{
            var addresses = [String]()
            for placemark in placemarks {
                addresses.append(self.formatAdressFromPlacemark(placemark: placemark))
            }
            self.showAddressTable(addresses: addresses, textField: currentTextField!, placemarks: placemarks, sender: sender)
        } else {
            self.showAlert("Address not found")
        }
    })
  }

  @IBAction func swapFields(_ sender: AnyObject) {
    swap(&destinationField1.text, &destinationField2.text)
    swap(&locationTuples[1].mapItem, &locationTuples[2].mapItem)
    swap(&self.enterButtonArray.filter{$0.tag == 2}.first!.isSelected, &self.enterButtonArray.filter{$0.tag == 3}.first!.isSelected)
  }
  
  func showAlert(_ alertString: String) {
    let alert = UIAlertController(title: nil, message: alertString, preferredStyle: .alert)
    let okButton = UIAlertAction(title: "OK",
      style: .cancel) { (alert) -> Void in
    }
    alert.addAction(okButton)
    present(alert, animated: true, completion: nil)
  }
    
    func showAddressTable(addresses: [String], textField: UITextField, placemarks: [CLPlacemark], sender: UIButton) {
        let addressTableView = AddressTableView(frame: UIScreen.main.bounds, style: UITableViewStyle.plain)
        addressTableView.addresses = addresses
        addressTableView.currentTextField = textField
        addressTableView.placemarkArray = placemarks
        addressTableView.mainViewController = self
        addressTableView.sender = sender
        addressTableView.delegate = addressTableView
        addressTableView.dataSource = addressTableView
        view.addSubview(addressTableView)
    }
  
  // The remaining methods handle the keyboard resignation/
  // move the view so that the first responders aren't hidden
  
  func moveViewUp() {
    if topMarginConstraint.constant != originalTopMargin {
      return
    }
    
    topMarginConstraint.constant -= 165
    UIView.animate(withDuration: 0.3, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  func moveViewDown() {
    if topMarginConstraint.constant == originalTopMargin {
      return
    }
    
    topMarginConstraint.constant = originalTopMargin
    UIView.animate(withDuration: 0.3, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
    
    func formatAdressFromPlacemark(placemark: CLPlacemark) -> String {
        return(placemark.addressDictionary!["FormattedAddressLines"] as! [String]).joined(separator: ", ")
    }
}

extension ViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    enterButtonArray.filter{$0.tag == textField.tag}.first!.isSelected = false
    locationTuples[textField.tag-1].mapItem = nil
    return true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    moveViewUp()
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    moveViewDown()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    view.endEditing(true)
    moveViewDown()
    return true
  }
}

extension ViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    CLGeocoder().reverseGeocodeLocation(locations.last!, completionHandler: {(placemarks, error) -> Void in
        if let placemarks = placemarks {
            let placemark = placemarks[0]
            self.locationTuples[0].mapItem = MKMapItem(placemark:MKPlacemark(coordinate: placemark.location!.coordinate, addressDictionary: placemark.addressDictionary as! [String:AnyObject]?))
            self.sourceField.text = self.formatAdressFromPlacemark(placemark: placemark)
            self.enterButtonArray.filter{$0.tag == 1}.first!.isSelected = true
        }
    })
  }
    
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
