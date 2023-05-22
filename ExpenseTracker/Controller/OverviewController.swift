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
    
    let chartDataHandler = ChartDataHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let spacing: CGFloat = 10.0
        var chartWidth: CGFloat
        var chartHeight:CGFloat
        let isLandscape = UIDevice.current.orientation.isLandscape
        
        if isLandscape {
            
            chartWidth = (view.safeAreaLayoutGuide.layoutFrame.width - 4 * spacing)/2
            chartHeight = view.safeAreaLayoutGuide.layoutFrame.height - 2 * spacing
            
            pieChart.frame = CGRect(x: spacing + view.safeAreaLayoutGuide.layoutFrame.minX, y: spacing + view.safeAreaLayoutGuide.layoutFrame.minY, width: chartWidth, height: chartHeight)
            barChart.frame = CGRect(x: spacing * 3 + chartWidth + view.safeAreaLayoutGuide.layoutFrame.minX, y: spacing + view.safeAreaLayoutGuide.layoutFrame.minY, width: chartWidth, height: chartHeight)
            
        } else {
            chartWidth = view.safeAreaLayoutGuide.layoutFrame.width - 2 * spacing
            chartHeight = (view.safeAreaLayoutGuide.layoutFrame.height - 4 * spacing)/2
            
            pieChart.frame = CGRect(x: spacing + view.safeAreaLayoutGuide.layoutFrame.minX, y: spacing + view.safeAreaLayoutGuide.layoutFrame.minY, width: chartWidth, height: chartHeight)
            barChart.frame = CGRect(x: spacing + view.safeAreaLayoutGuide.layoutFrame.minX, y: 3 * spacing + view.safeAreaLayoutGuide.layoutFrame.minY + chartHeight, width: chartWidth, height: chartHeight)
        }
        view.addSubview(pieChart)
        view.addSubview(barChart)
        expenses = db.read()
        
        let filteredExpense = chartDataHandler.filterDataForCharts(expenses:expenses)
        let summarisedDataForCharts = chartDataHandler.prepareChartData(expenses: filteredExpense)
        let dataForPieChart = chartDataHandler.prepareDataForPieChart(preparedDataForCharts: summarisedDataForCharts)
        let pieChartEntries = chartDataHandler.preparePieChartEntry(preparedDataForPieChart: dataForPieChart)
        let barChartEntries = chartDataHandler.prepareBarChartEntry(preparedDataForCharts: summarisedDataForCharts)
        let chartLegendsLabel = chartDataHandler.getChartsLegends(preparedDataForCharts: summarisedDataForCharts)
        
        let set = PieChartDataSet(entries: pieChartEntries)
        set.colors = ChartColorTemplates.material()
        let data = PieChartData(dataSet: set)
        set.label = chartLegendsLabel
        
        pieChart.data = data
        
        view.addSubview(barChart)
        
        let setBar = BarChartDataSet(entries: barChartEntries)
        setBar.colors = ChartColorTemplates.joyful()
        setBar.label = chartLegendsLabel
        let dataBar = BarChartData(dataSet: setBar)
        barChart.data = dataBar
        
        barChart.leftAxis.axisMinimum = 0
        barChart.rightAxis.enabled = false
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.drawAxisLineEnabled = true
        barChart.xAxis.drawLabelsEnabled = false
        
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        
        
    }
}

