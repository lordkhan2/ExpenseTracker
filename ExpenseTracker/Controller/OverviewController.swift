//
//  ViewController.swift
//  ExpenseTracker
//
//  Created by Farhan Khan on 27/4/23.
//

import UIKit
import Charts

class OverviewController: UIViewController, ChartViewDelegate,UIScrollViewDelegate,UITableViewDataSource, UITableViewDelegate {
    
    var pieChart = PieChartView()
    var barChart = BarChartView()
    var categoryCountChart = BarChartView()
    var lineGraph = LineChartView()
    var scatterChart = ScatterChartView()
    var cumulativeLineChart = LineChartView()
    
    var dataForPieChart:[SummarisedExpense] = [SummarisedExpense]()
    var selectedExpense:[Expense] = [Expense]()
    var summarisedDataForCharts:[SummarisedExpense] = [SummarisedExpense]()
    var categoryCountArray:[CategoryCountExpense] = [CategoryCountExpense]()
    var groupedDailyExpenses:[DailyTotalExpense] = [DailyTotalExpense]()
    var cumulativeExpenses:[CumulativeExpense] = [CumulativeExpense]()
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var pieChartView: UIView!
    @IBOutlet weak var barChartView: UIView!
    @IBOutlet weak var categoryCountChartView: UIView!
    
    var db = DBManager()
    var expenses = Array<Expense>()
    
    let chartDataHandler = ChartDataHandler()
    
    // Create a scroll view
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChartsData()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Set up the scroll view
        scrollView = UIScrollView(frame: CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: (view.frame.height - view.safeAreaInsets.top) * 0.62))
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: view.frame.width * 5, height: scrollView.frame.height)
        
        // Create three views to represent the pages
        let page1 = createPage(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.frame.height), color: .systemBackground, text: "Top Three Expenses Percentage")
        let page2 = createPage(frame: CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: scrollView.frame.height), color: .systemBackground, text: "Top Three Expenses Sum")
        let page3 = createPage(frame: CGRect(x: view.frame.width * 2, y: 0, width: view.frame.width, height: scrollView.frame.height), color: .systemBackground, text: "Transactions Summary by Frenquency")
        let page4 = createPage(frame: CGRect(x: view.frame.width * 3, y: 0, width: view.frame.width, height: scrollView.frame.height), color: .systemBackground, text: "Daily Expenses for the Current Month")
        let page5 = createPage(frame: CGRect(x: view.frame.width * 4, y: 0, width: view.frame.width, height: scrollView.frame.height), color: .systemBackground, text: "Cumulative Expense for Current Month")
        
        // Add the pages to the scroll view
        page1.addSubview(pieChart)
        page2.addSubview(barChart)
        page3.addSubview(categoryCountChart)
        page4.addSubview(scatterChart)
        page5.addSubview(cumulativeLineChart)
        scrollView.addSubview(page1)
        scrollView.addSubview(page2)
        scrollView.addSubview(page3)
        scrollView.addSubview(page4)
        scrollView.addSubview(page5)
        
        //Set delegate for charts
        pieChart.delegate = self
        barChart.delegate = self
        categoryCountChart.delegate = self
        scatterChart.delegate = self
        cumulativeLineChart.delegate = self
        
        // Add the scroll view to the main view
        view.addSubview(scrollView)
        
        // Add page control
        pageControl = UIPageControl()
        pageControl.numberOfPages = 5
        pageControl.currentPageIndicatorTintColor = UIColor.red
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
        view.addSubview(pageControl)
        
        // Create a table view
        //tableView = UITableView(frame: .zero)
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "ExpenseTableCell", bundle: .main), forCellReuseIdentifier: "ExpenseTableCell")
        view.addSubview(tableView)
        
        updateChartsData()
        updateLayoutForOrientationChange()
    }
    
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        let offsetX = scrollView.frame.width * CGFloat(currentPage)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    func updateChartsData(){
        _ = chartDataHandler.getCurrentMonthAndYear()
        expenses = db.read()
        let filteredCategoryCountArray = chartDataHandler.filterDataForCharts(expenses: expenses)
        categoryCountArray = chartDataHandler.getCategories(expenses: filteredCategoryCountArray)
        let categoryCountCharPrep = chartDataHandler.prepareCategoryCountChartEntry(preparedDataForCharts: categoryCountArray)
        groupedDailyExpenses = chartDataHandler.getGroupedMonthExpenses(expenses: filteredCategoryCountArray)
        let lineGraphDailyExpenseData = chartDataHandler.prepareGroupedMonthExpenses(preparedDataForCharts: groupedDailyExpenses)
        let filteredExpense = chartDataHandler.filterDataForCharts(expenses:expenses)
        
        summarisedDataForCharts = chartDataHandler.prepareChartData(expenses: filteredExpense)
        dataForPieChart = chartDataHandler.prepareDataForPieChart(preparedDataForCharts: summarisedDataForCharts)
        let pieChartEntries = chartDataHandler.preparePieChartEntry(preparedDataForPieChart: dataForPieChart)
        let barChartEntries = chartDataHandler.prepareBarChartEntry(preparedDataForCharts: summarisedDataForCharts)
        let chartLegendsLabel = chartDataHandler.getChartsLegends(preparedDataForCharts: summarisedDataForCharts)
        
        cumulativeExpenses = chartDataHandler.getCurrentMonthCumulativeExpenses(dailyTotalExpenses: groupedDailyExpenses)
        let preparedCumulativeExpenses = chartDataHandler.prepareCumulativeExpenses(preparedDataForCharts: cumulativeExpenses)
        let preparedSetCapLineData = chartDataHandler.prepareSecondCumulativeExpensesLine(preparedDataForCharts: cumulativeExpenses)
        
        let set = PieChartDataSet(entries: pieChartEntries)
        set.colors = ChartColorTemplates.material()
        let data = PieChartData(dataSet: set)
        set.label = chartLegendsLabel
        
        pieChart.data = data
        pieChart.data?.setValueFont(NSUIFont.systemFont(ofSize: 13.0,weight: UIFont.Weight.medium))
        pieChart.animate(xAxisDuration: 1.0)
        
        let setBar = BarChartDataSet(entries: barChartEntries)
        setBar.colors = ChartColorTemplates.joyful()
        setBar.label = chartLegendsLabel
        let dataBar = BarChartData(dataSet: setBar)
        barChart.data = dataBar
        barChart.barData?.setValueFont(NSUIFont.systemFont(ofSize: 12.0,weight: UIFont.Weight.medium))
        
        barChart.leftAxis.axisMinimum = 0
        barChart.rightAxis.enabled = false
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.drawAxisLineEnabled = true
        barChart.xAxis.drawLabelsEnabled = false
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        barChart.xAxis.axisLineWidth = 1
        barChart.leftAxis.axisLineWidth = 1
        barChart.animate(xAxisDuration: 1.0)

        
        // barchart 2 configuration
        let categoryCountSet = BarChartDataSet(entries: categoryCountCharPrep)
        categoryCountSet.colors = ChartColorTemplates.material()
        categoryCountSet.label = "Click Bar To See Details"
        let dataCategoryCount = BarChartData(dataSet: categoryCountSet)
        categoryCountChart.data = dataCategoryCount
        categoryCountChart.barData?.setValueFont(NSUIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.medium))
        
        categoryCountChart.leftAxis.axisMinimum = 0
        categoryCountChart.rightAxis.enabled = false
        categoryCountChart.xAxis.labelPosition = .bottom
        categoryCountChart.xAxis.drawAxisLineEnabled = true
        categoryCountChart.xAxis.drawLabelsEnabled = false
        categoryCountChart.xAxis.axisLineWidth = 1
        categoryCountChart.leftAxis.axisLineWidth = 1
        categoryCountChart.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        categoryCountChart.xAxis.drawGridLinesEnabled = false
        categoryCountChart.leftAxis.drawGridLinesEnabled = false
        categoryCountChart.rightAxis.drawGridLinesEnabled = false
        categoryCountChart.animate(xAxisDuration: 1.0)
        
        //line chart 1 configuration
                
        let scatterGraphSet = ScatterChartDataSet(entries: lineGraphDailyExpenseData, label: "")
        
        scatterGraphSet.drawValuesEnabled = true
        scatterGraphSet.scatterShapeHoleColor = .systemBlue
        scatterGraphSet.shapeRenderer = CircleShapeRenderer()
        //scatterGraphSet.scatterShapeSize = 10
        scatterGraphSet.scatterShapeHoleRadius = 4
        scatterGraphSet.setColor(.white)
        
        scatterGraphSet.drawHorizontalHighlightIndicatorEnabled = false
        let scatterData = ScatterChartData(dataSet: scatterGraphSet)
        scatterData.setDrawValues(false)
        scatterChart.data = scatterData
        scatterChart.backgroundColor = .systemBackground
        scatterChart.rightAxis.enabled = false
        scatterChart.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        scatterChart.leftAxis.setLabelCount(6, force: false)
        scatterChart.leftAxis.labelPosition = .outsideChart
        scatterChart.leftAxis.axisMinimum = 0
        scatterChart.leftAxis.drawGridLinesEnabled = false
        
        scatterChart.xAxis.labelPosition = .bottom
        scatterChart.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        scatterChart.xAxis.setLabelCount(6, force: false)
        scatterChart.xAxis.axisMinimum = 0
        scatterChart.xAxis.drawGridLinesEnabled = false
        scatterChart.animate(xAxisDuration: 1.0)
        scatterChart.xAxis.axisLineWidth = 1
        scatterChart.leftAxis.axisLineWidth = 1

        // cumulative line chart 1 configuration
        
        let lineGraphSet = LineChartDataSet(entries: preparedCumulativeExpenses, label: "Acummulative Expense")
        
        lineGraphSet.mode = .cubicBezier
        lineGraphSet.drawCirclesEnabled = false
        lineGraphSet.lineWidth = 3
        lineGraphSet.setColor(.systemMint)
        lineGraphSet.fill = ColorFill(color: .clear)
        lineGraphSet.fillAlpha = 0.8
        lineGraphSet.drawFilledEnabled = true
        
        let setCapLine = LineChartDataSet(entries: preparedSetCapLineData, label: "Monthly Cap")
        
        setCapLine.mode = .cubicBezier
        setCapLine.drawCirclesEnabled = false
        setCapLine.lineWidth = 1.5
        setCapLine.setColor(.systemPink)
        setCapLine.fill = ColorFill(color: .clear)
        setCapLine.fillAlpha = 0.8
        setCapLine.drawFilledEnabled = true
        
        let setCapData = LineChartData(dataSets: [lineGraphSet, setCapLine])
        setCapData.setDrawValues(false)
        cumulativeLineChart.data = setCapData
        
        
        cumulativeLineChart.backgroundColor = .systemBackground
        cumulativeLineChart.rightAxis.enabled = false
        
        cumulativeLineChart.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        cumulativeLineChart.leftAxis.setLabelCount(6, force: false)
        cumulativeLineChart.leftAxis.labelPosition = .outsideChart
        cumulativeLineChart.leftAxis.axisMinimum = 0
        cumulativeLineChart.leftAxis.drawGridLinesEnabled = false
        
        cumulativeLineChart.xAxis.labelPosition = .bottom
        cumulativeLineChart.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        cumulativeLineChart.xAxis.setLabelCount(6, force: false)
        cumulativeLineChart.xAxis.drawGridLinesEnabled = false
        cumulativeLineChart.animate(xAxisDuration: 1.0,yAxisDuration: 2.0)
        cumulativeLineChart.xAxis.axisLineWidth = 1
        cumulativeLineChart.leftAxis.axisLineWidth = 1
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animate(alongsideTransition: { _ in
//            //self.updateLayoutForOrientationChange()
//        }, completion: nil)
//
//        super.viewWillTransition(to: size, with: coordinator)
//    }
    
    // create a page view
    func createPage(frame: CGRect, color: UIColor, text: String) -> UIView {
        let pageView = UIView(frame: frame)
        pageView.backgroundColor = color
        
        let label = UILabel(frame: CGRect(x: 0, y: scrollView.frame.height * 0.05 + view.safeAreaInsets.top, width: frame.width, height: scrollView.frame.height * 0.1))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = text
        pageView.addSubview(label)
        
        return pageView
    }
    
    func updateLayoutForOrientationChange() {
        let isLandscape = UIDevice.current.orientation.isLandscape
        
        let scrollViewHeight: CGFloat = isLandscape ? (view.frame.height - view.safeAreaInsets.bottom - 5) : (view.frame.height - view.safeAreaInsets.top) * 0.62 + view.safeAreaInsets.top
        
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollViewHeight)
        scrollView.contentSize = CGSize(width: view.frame.width * 5, height: scrollView.frame.height)
        
        for (index, subview) in scrollView.subviews.enumerated() {
            subview.removeFromSuperview()
            subview.frame = CGRect(x: view.frame.width * CGFloat(index), y: 0, width: view.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(subview)
        }
        
        if isLandscape{
            pageControl.frame = CGRect(x: 0, y: scrollView.frame.maxY - 5 + view.safeAreaInsets.top, width: view.frame.width, height: 5)
            pageControl.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }else{
            pageControl.frame = CGRect(x: 0, y: scrollView.frame.maxY - 10, width: view.frame.width, height: 50)
        }
        
        if isLandscape {
            tableView.isHidden = true
        } else {
            tableView.frame = CGRect(x: 0, y: pageControl.frame.maxY, width: view.frame.width, height: view.frame.height - pageControl.frame.maxY)
            tableView.isHidden = false
        }
        
        var pieChartWidth: CGFloat
        var pieChartHeight:CGFloat
        var pieChartXOrigin: CGFloat
        var pieChartYOrigin:CGFloat
        
        var chartWidth: CGFloat
        var chartHeight:CGFloat
        var chartXOrigin: CGFloat
        var chartYOrigin:CGFloat
        var labelYOrigin:CGFloat
        
        
        if isLandscape {

            labelYOrigin = scrollView.frame.height * 0.15
            
            pieChartHeight = scrollView.frame.height * 0.83
            pieChartWidth = pieChartHeight * 1.2
            pieChartYOrigin = labelYOrigin + scrollView.frame.origin.y
            pieChartXOrigin = (scrollView.frame.width - pieChartWidth) * 0.5
            
            chartHeight = scrollView.frame.height * 0.83
            chartWidth = scrollView.frame.width * 0.8
            chartYOrigin = labelYOrigin + scrollView.frame.origin.y
            chartXOrigin = (scrollView.frame.width - chartWidth) * 0.5
            
            pieChart.frame = CGRect(x: pieChartXOrigin, y: pieChartYOrigin, width: pieChartWidth, height: pieChartHeight)
            barChart.frame = CGRect(x: pieChartXOrigin, y: pieChartYOrigin, width: pieChartWidth, height: pieChartHeight)
            categoryCountChart.frame = CGRect(x: chartXOrigin, y: chartYOrigin, width: chartWidth, height: chartHeight)
            scatterChart.frame = CGRect(x: chartXOrigin, y: chartYOrigin, width: chartWidth, height: chartHeight)
            cumulativeLineChart.frame = CGRect(x: chartXOrigin, y: chartYOrigin, width: chartWidth, height: chartHeight)

        } else {
            
            labelYOrigin = scrollView.frame.height * 0.15
            chartHeight = scrollView.frame.height * 0.7
            chartWidth = scrollView.frame.width * 0.9
            chartYOrigin = labelYOrigin + scrollView.frame.origin.y + view.safeAreaInsets.top
            chartXOrigin = (scrollView.frame.width - chartWidth) * 0.5

            pieChart.frame = CGRect(x: chartXOrigin, y: chartYOrigin, width: chartWidth, height: chartHeight)
            barChart.frame = CGRect(x: chartXOrigin, y: chartYOrigin, width: chartWidth, height: chartHeight)
            categoryCountChart.frame = CGRect(x: chartXOrigin, y: chartYOrigin, width: chartWidth, height: chartHeight)
            scatterChart.frame = CGRect(x: chartXOrigin, y: chartYOrigin, width: chartWidth, height: chartHeight)
            cumulativeLineChart.frame = CGRect(x: chartXOrigin, y: chartYOrigin, width: chartWidth, height: chartHeight)
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if type(of: scrollView) != UITableView.self{
            let pageIndex = abs(round(scrollView.contentOffset.x / view.frame.width))
            if let pageControl = pageControl{
                pageControl.currentPage = Int(pageIndex)
            }
        }
    }
    
    @objc func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight){
        switch pageControl.currentPage {
        case 0:
            selectedExpense = dataForPieChart[Int(entry.x)].subExpenses
        case 1:
            selectedExpense = summarisedDataForCharts[Int(entry.x-1)].subExpenses
        case 2:
            selectedExpense = categoryCountArray[Int(entry.x-1)].subExpenses
        case 3:
            selectedExpense = groupedDailyExpenses[Int(entry.x-1)].subExpenses
        case 4:
            selectedExpense = cumulativeExpenses[Int(entry.x-1)].subExpenses
        default:
            selectedExpense = [Expense]()
        }
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedExpense.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExpenseTableCell = tableView.dequeueReusableCell(withIdentifier: "ExpenseTableCell", for: indexPath) as! ExpenseTableCell
        let thisExpense = selectedExpense[indexPath.row]
        cell.dateLabel.text = thisExpense.expenseDateString
        cell.categoryLabel.text = thisExpense.category
        cell.amountLabel.text = "$\(thisExpense.amount.description)"
        cell.expenseCategoryImage(expenseCategory: thisExpense.category)
        cell.selectionStyle = .none
        return cell
    }
}

