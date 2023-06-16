//
//  BarChartFormatter.swift
//  ExpenseTracker
//
//  Created by Cube on 6/16/23.
//

import UIKit
import Foundation
import Charts

@objc(BarChartFormatter)
public class BarChartFormatter: NSObject, IAx
{
  var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

  public func stringForValue(value: Double, axis: AxisBase?) -> String
  {
    return months[Int(value)]
  }
}
