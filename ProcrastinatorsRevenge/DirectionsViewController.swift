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

class DirectionsViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var totalTimeLabel: UILabel!
  @IBOutlet weak var directionsTableView: DirectionsTableView!
  
  var activityIndicator: UIActivityIndicatorView?
  var locationArray: [(textField: UITextField?, mapItem: MKMapItem?)]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    directionsTableView.contentInset = UIEdgeInsetsMake(-36, 0, -20, 0)
  }

  func addActivityIndicator() {
    activityIndicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
    activityIndicator?.activityIndicatorViewStyle = .whiteLarge
    activityIndicator?.backgroundColor = view.backgroundColor
    activityIndicator?.startAnimating()
    view.addSubview(activityIndicator!)
  }
  
  func hideActivityIndicator() {
    if activityIndicator != nil {
      activityIndicator?.removeFromSuperview()
      activityIndicator = nil
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
    automaticallyAdjustsScrollViewInsets = false
  }
}

extension DirectionsViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    
    let polylineRenderer = MKPolylineRenderer(overlay: overlay)
    if (overlay is MKPolyline) {
      polylineRenderer.strokeColor = UIColor.blue.withAlphaComponent(0.75)
      polylineRenderer.lineWidth = 5
    }
    return polylineRenderer
  }
}
