//
//  ViewController.swift
//  ExpenseTracker
//
//  Created by Farhan Khan on 27/4/23.
//

import UIKit
import Charts
class ViewController: UIViewController, ChartViewDelegate {
    var pieChart = PieChartView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pieChart.frame = CGRect(x:0, y:0, width:self.view.frame.size.width, height: self.view.frame.size.width)
        pieChart.center = view.center
        view.addSubview(pieChart)
        
        
        var entries = [ChartDataEntry]()
//        for x in 0..<10 {
//            entries.append(ChartDataEntry(x: Double(x), y: Double(x)))
//        }
        let expenseData = [
            (0, 1000.0),
            (1, 500.0),
            (2, 300.0),
            (3, 800.0),
            (4, 900.0),
            // Add more expense categories and amounts as needed
        ]
        for (number, amount) in expenseData {
            let entry = ChartDataEntry(x: Double(number), y: Double(amount))
            entries.append(entry)
        }
   
        let set = PieChartDataSet(entries: entries)
        
        set.colors = ChartColorTemplates.material()
        let data = PieChartData(dataSet: set)
      
        set.label = "Monthly Expense Breakdown"
        pieChart.data = data
       
        
    }


}

