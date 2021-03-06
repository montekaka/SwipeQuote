//
//  SwipeViewController.swift
//  Dashcast
//
//  Created by Jia Chen on 6/30/15.
//  Copyright (c) 2015 com.bruinSquare. All rights reserved.
//

import UIKit
import performSelector_swift
import UIColor_FlatColors
import Cartography
import ReactiveUI
import ZLSwipeableViewSwift
import SwiftyJSON

class SwipeViewController: UIViewController {
    var swipeableView: ZLSwipeableView!
    
    var objects = [[String: String]]()
    
    var colorIndex = 0
    var loadCardsFromXib = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.loadViews()
    }
    
    var arrayOfInts: [Int] = []
    var currentCardIndex = 0
    let firstActivityItem = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Great Fxxking Startup Advice"
        self.navigationItem.hidesBackButton = true
        
        // parse data from json
        // http://www.hackingwithswift.com/read/7/3/parsing-json-nsdata-and-swiftyjson
        
        var urlString = "https://spreadsheets.google.com/feeds/list/16y6-IWK996t0ILL5YUKvHgXEISiMWNAP7HwhV4869no/od6/public/values?alt=json"
        
        if let url = NSURL(string: urlString) {
            
            if let data = NSData(contentsOfURL: url, options: .allZeros, error: nil) {
                
                let json = JSON(data: data)
                parseJSON(json)
            }
            else{
                println("something wrong of the json data")
            }
        }
        else{
            println("something wrong of the url")
        }

        
        // setup swipe view
        navigationController?.setToolbarHidden(false, animated: false)
        view.backgroundColor = UIColor.whiteColor()
        view.clipsToBounds = true
                
        swipeableView = ZLSwipeableView()
        view.addSubview(swipeableView)
        
        /*
        swipeableView.didStart = {view, location in
            println("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            println("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            println("Did end swiping view at location: \(location)")
        }
        swipeableView.didSwipe = {view, direction, vector in
            println("Did swipe view in direction: \(direction), vector: \(vector)")
        }
        
        swipeableView.didCancel = {view in
            println("Did cancel swiping view")
            // setup the social view
        }
        */
        self.swipeableView.didSwipe = {view, direction, vector in
            println("Did end swiping view at location: \(direction) before: \(self.currentCardIndex)")
            self.currentCardIndex = self.currentCardIndex + 1
            println("after swipe \(self.currentCardIndex)")
        }


        //
        
        swipeableView.nextView = {
            if self.arrayOfInts.count == 3 {
                self.currentCardIndex = 1
            }
            if self.colorIndex < 10 {
                
                let diceRoll = Int(arc4random_uniform(UInt32(self.objects.count)))
                self.arrayOfInts.append(diceRoll)
                var cardView = CardView(frame: self.swipeableView.bounds)
                cardView.backgroundColor =  UIColor.randomFlatColor()
                //cardView.backgroundColor =  UIColor.redColor()
                
                var quoteTitle = self.objects[diceRoll]["title"]
                var currentTitleId = self.arrayOfInts[self.currentCardIndex]

                var firstQuoteTitle = self.objects[currentTitleId]["title"]!

                cardView.textLabel.text = quoteTitle
                cardView.textLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn:cardView.backgroundColor, isFlat:true)

                println(diceRoll)
                println(self.currentCardIndex)
                // we don't want the card stop
                // this will be an infinitie loop!
                
                //self.colorIndex++
                
                
                if self.loadCardsFromXib {
                    var contentView = NSBundle.mainBundle().loadNibNamed("CardContentView", owner: self, options: nil).first! as! UIView
                    contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
                    contentView.backgroundColor = cardView.backgroundColor
                    cardView.addSubview(contentView)
                    
                    // This is important:
                    // https://github.com/zhxnlai/ZLSwipeableView/issues/9
                    /*// Alternative:
                    let metrics = ["width":cardView.bounds.width, "height": cardView.bounds.height]
                    let views = ["contentView": contentView, "cardView": cardView]
                    cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView(width)]", options: .AlignAllLeft, metrics: metrics, views: views))
                    cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView(height)]", options: .AlignAllLeft, metrics: metrics, views: views))
                    */
                    layout(contentView, cardView) { view1, view2 in
                        view1.left == view2.left
                        view1.top == view2.top
                        view1.width == cardView.bounds.width
                        view1.height == cardView.bounds.height
                    }

                }
                
                self.swipeableView.didCancel = {view in
                    //println("Did cancel swiping view \(self.currentCardIndex) \(firstQuoteTitle)")
                    // setup the social view
                    let activityItems = ["\(firstQuoteTitle) #greatfuckingstartupadvice"]
                    let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    self.presentViewController(activityViewController, animated: true, completion: nil)
                }
                
                return cardView
            }
            return nil
        }
        
        layout(swipeableView, view) { view1, view2 in            
            view1.left == view2.left+50
            view1.right == view2.right-50
            view1.top == view2.top + 120
            view1.bottom == view2.bottom - 100
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseJSON(json: JSON) {
        for result in json["feed"]["entry"].arrayValue {
            let title = result["gsx$advice"]["$t"].stringValue
            let author = result["gsx$author"]["$t"].stringValue
            let obj = ["title": title, "author": author]
            objects.append(obj)
        }
    }
}
