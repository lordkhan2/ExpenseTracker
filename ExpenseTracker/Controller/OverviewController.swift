//
//  ViewController.swift
//  ExpenseTracker
//
//  Created by Farhan Khan on 27/4/23.
//

import UIKit
import Charts
class OverviewController: UIViewController, ChartViewDelegate {
    var pieChart = PieChartView()
    var barChart = BarChartView()
    
    var db = DBManager()
    var expenses = Array<Expense>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let chartSize: CGFloat = 300.0
        let spacing: CGFloat = 50.0
        let isLandscape = UIDevice.current.orientation.isLandscape
        
        if isLandscape {
            let availableWidth = view.bounds.width - 3 * spacing - chartSize
            let availableHeight = view.bounds.height - 2 * spacing - 30
            
            pieChart.frame = CGRect(x: spacing, y: spacing, width: chartSize, height: availableHeight)
            barChart.frame = CGRect(x: spacing * 2 + chartSize, y: spacing, width: availableWidth, height: availableHeight)
        } else {
            let availableHeight = view.bounds.height - 3 * spacing - (chartSize + 50)
            let availableWidth = view.bounds.width - 2 * spacing
            
            pieChart.frame = CGRect(x: spacing, y: spacing, width: availableWidth, height: chartSize)
            barChart.frame = CGRect(x: spacing, y: spacing * 2 + chartSize, width: availableWidth, height: availableHeight)
        }
        view.addSubview(pieChart)
        view.addSubview(barChart)
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
        
        var entriesBar = [BarChartDataEntry]()
        for (number, amount) in expenseData {
            let entry = BarChartDataEntry(x: Double(number), y: Double(amount))
            entriesBar.append(entry)
        }
    
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

