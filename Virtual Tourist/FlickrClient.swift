//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/16/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation
import CoreData

class FlickrClient {
    
    typealias Completed = (photoURLs: [[String: String]]?) -> Void
    
    static let sharedInstance = FlickrClient()
    
    /**
     Gets a random page from searching Flickr at the url with the methodParameters.
     
     - Parameter methodParameters: Parameters to search for on Flickr.
     - Parameter completionHandler: An array of dictionaries with the photo's large and medium url.
    */
    private func getImageURLsFromFlickrBySearch(methodParameters: [String:AnyObject], completionHandler: Completed) {
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(error: String) {
                print(error)
                completionHandler(photoURLs: nil)
            }
            
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String where stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            
            self.getImageURLsFromFlickrBySearch(methodParameters, withPageNumber: randomPage, completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    /**
     Gets the url for photos with the methodParameters and on a certain page, gets the medium and large url.
     
     - Parameter methodParameters: Parameters to search for on Flickr.
     - Parameter withPageNumber: The specific page number to get urls from.
     - Parameter completionHandler: An array of dictionaries with the photo's large and medium url.
     */
    private func getImageURLsFromFlickrBySearch(methodParameters: [String:AnyObject], withPageNumber: Int, completionHandler: Completed) {
        
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber
        
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParametersWithPageNumber))
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(error: String) {
                print(error)
                completionHandler(photoURLs: nil)
            }
            
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String where stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            if photosArray.count == 0 {
                completionHandler(photoURLs: [])
            } else {
                var photoURLsArray = [[String: String]]()
                
                for photo in photosArray {
                    
                    if photoURLsArray.count == 21 {
                        break
                    }
                    
                    guard let imageUrlString = photo[Constants.FlickrResponseKeys.MediumURL] as? String else {
                        continue
                    }
                    
                    guard let largeImageUrlString = photo[Constants.FlickrResponseKeys.LargeURL] as? String else {
                        continue
                    }
                    
                    let photoURLs = [Constants.FlickrResponseKeys.MediumURL: imageUrlString, Constants.FlickrResponseKeys.LargeURL: largeImageUrlString]
                    
                    photoURLsArray.append(photoURLs)
                }
                
                completionHandler(photoURLs: photoURLsArray)
            }
        }
        
        task.resume()
    }
    
    /**
     Gets the photos urls, downloads the image and creates the image in the NSManagedObjectContext.
     
     - Parameter pin: The pin the images are for.
     - Parameter context: The NSManagedObjectContext to add the photos to.
     - Parameter completionHandler: (Optional) Passes an error if it occured.
     */
    func getImagesForPin(pin: Pin, context: NSManagedObjectContext, completionHandler: (error: NSError?) -> Void) {
        
        let methodParameters = [
            FlickrClient.Constants.FlickrParameterKeys.Method: FlickrClient.Constants.FlickrParameterValues.SearchMethod,
            FlickrClient.Constants.FlickrParameterKeys.APIKey: FlickrClient.Constants.FlickrParameterValues.APIKey,
            FlickrClient.Constants.FlickrParameterKeys.SafeSearch: FlickrClient.Constants.FlickrParameterValues.UseSafeSearch,
            FlickrClient.Constants.FlickrParameterKeys.Latitude: String(pin.coordinate.latitude),
            FlickrClient.Constants.FlickrParameterKeys.Longitude: String(pin.coordinate.longitude),
            FlickrClient.Constants.FlickrParameterKeys.Radius: FlickrClient.Constants.FlickrParameterValues.Radius,
            FlickrClient.Constants.FlickrParameterKeys.Extras: FlickrClient.Constants.FlickrParameterValues.MediumURL + ",+" + FlickrClient.Constants.FlickrParameterValues.LargeURL,
            FlickrClient.Constants.FlickrParameterKeys.PerPage: FlickrClient.Constants.FlickrParameterValues.PerPage,
            FlickrClient.Constants.FlickrParameterKeys.Format: FlickrClient.Constants.FlickrParameterValues.ResponseFormat,
            FlickrClient.Constants.FlickrParameterKeys.NoJSONCallback: FlickrClient.Constants.FlickrParameterValues.DisableJSONCallback
        ]
            
        FlickrClient.sharedInstance.getImageURLsFromFlickrBySearch(methodParameters, completionHandler: { (photoURLs) in
            if let photoURLs = photoURLs {
                
                guard photoURLs.count > 0 else {
                    completionHandler(error: NSError(domain: "NoPhotos", code: 2, userInfo: nil))
                    return
                }
                
                for photo in photoURLs {
                    let photoPath = photo[FlickrClient.Constants.FlickrResponseKeys.MediumURL]!
                    let image = Photo(imageData: nil, smallImage: photoPath, largeImage: photo[FlickrClient.Constants.FlickrResponseKeys.LargeURL], context: context)
                    image.pin = pin
                    self.taskForGETImage(photoPath, completionHandler: { (imageData, error) in
                        if let imageData = imageData {
                            image.imageData = imageData
                        }
                    })
                }
                completionHandler(error: nil)
            } else {
                completionHandler(error: NSError(domain: "DownloadFailed", code: 1, userInfo: nil))
            }
        })
    }
    
    /**
     Downloads an image from the internet.
     
     - Parameter filePath: The file path for the image to be downloaded.
     - Parameter completionHandler: (Optional) Passes the image data if it was successful and passes an error if it occured.
     
     - Returns: NSURLSessionTask of the current downloading task.
     */
    func taskForGETImage(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionTask {
        let session = NSURLSession.sharedSession()
        
        let url = NSURL(string: filePath)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func errorOccured() {
                completionHandler(imageData: nil, error: error)
            }
            
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                errorOccured()
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                errorOccured()
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                errorOccured()
                return
            }
            
            completionHandler(imageData: data, error: nil)
        }
        
        task.resume()
        
        return task
    }
    
    /**
     Gets the photos urls, downloads the image and creates the image in the NSManagedObjectContext.
     
     - Parameter parameters: Parameters to add to the url.
     
     - Returns: NSURL of the new url created.
     */
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
}