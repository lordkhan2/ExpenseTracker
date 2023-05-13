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
    var lineChart = LineChartView()
    var barChart = BarChartView()
    
    var db = DBManager()
    var expenses = Array<Expense>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLayoutSubviews()
       
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let chartSize: CGFloat = 300.0
//        pieChart.frame = CGRect(x:0, y:0, width:self.view.frame.size.width, height: self.view.frame.size.width)
        pieChart.frame = CGRect(x:50, y:100, width:chartSize, height: chartSize)
        //pieChart.center = view.center
        view.addSubview(pieChart)
        expenses = db.read()
        var entries = [ChartDataEntry]()
        var expenseData = [(Int, Double)]()
        for expense in expenses {
            let expenseCategory = expense.id
                let expenseAmount = expense.amount
                
                let expenseTuple = (expenseCategory, expenseAmount)
                expenseData.append(expenseTuple)
        }
        
       
        for (number, amount) in expenseData {
            let entry = ChartDataEntry(x: Double(number), y: Double(amount))
            entries.append(entry)
        }
   
        let set = PieChartDataSet(entries: entries)
        
        set.colors = ChartColorTemplates.material()
        let data = PieChartData(dataSet: set)
      
        set.label = "Monthly Expense Breakdown"
        pieChart.data = data
        
//        lineChart.frame = CGRect(x:50, y:400, width:chartSize, height: chartSize)
//        view.addSubview(lineChart)
//
//        let setLine = LineChartDataSet(entries: entries)
//        setLine.colors = ChartColorTemplates.material()
//        let dataLine = LineChartData(dataSet: setLine)
//        lineChart.data = dataLine
        
        var entriesBar = [BarChartDataEntry]()
        for (number, amount) in expenseData {
            let entry = BarChartDataEntry(x: Double(number), y: Double(amount))
            entriesBar.append(entry)
        }
        
        barChart.frame = CGRect(x:50, y:400, width:chartSize, height: chartSize)
        view.addSubview(barChart)
        
        let setBar = BarChartDataSet(entries: entriesBar)
        setBar.colors = ChartColorTemplates.joyful()
        let dataBar = BarChartData(dataSet: setBar)
        barChart.data = dataBar
        
        barChart.rightAxis.enabled = false
        barChart.xAxis.labelPosition = .bottom
        
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
      
        
    }


}

