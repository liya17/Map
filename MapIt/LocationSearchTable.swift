//
//  LocationSearchTable.swift
//  MapIt
//
//  Created by Liya Wu-17 on 7/5/16.
//  Copyright © 2016 ms. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    
    var matchingItems:[MKMapItem] = [] // use this later on to stash search results for easy access
    var mapView: MKMapView? = nil // Search queries rely on a map region to prioritize local results. The mapView variable is a handle to the map from the previous screen
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
}

extension LocationSearchTable : UISearchResultsUpdating {

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let mapView = mapView, // guard statement unwraps the optional values for mapView and the search bar text
        let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest() //  A search request is comprised of a search string, and a map region that provides location context. The search string comes from the search bar text, and the map region comes from the mapView
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request) // performs the actual search on the request object
        
        //executes the search query and returns a MKLocalSearchResponse object which contains an array of mapItems. You stash these mapItems inside matchingItems, and then reload the table.
        search.startWithCompletionHandler { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    // creates an address for each search result
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}

extension LocationSearchTable {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count // determines the number of table rows
    }
    
    // Each cell was configured with an identifier of cell in a previous section. The cell’s built-in textLabel is set to the placemark name of the Map Item
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem) // refers to the parse address
        return cell
    }
}

// groups UITableViewDelegate methods together
extension LocationSearchTable {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark // When a search result row is selected, you find the appropriate placemark based on the row number
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem) // pass the placemark to the map via the custom protocol method
        dismissViewControllerAnimated(true, completion: nil) // close the search results modal so the user can see the map
    }
}