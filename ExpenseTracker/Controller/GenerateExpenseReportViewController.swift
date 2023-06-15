import UIKit
import PDFKit

class GenerateExpenseReportViewController: UIViewController {
    var db = DBManager()
    var expenses = Array<Expense>()
    let pdfView = PDFView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfView)
        expenses = db.read()

        let newDocument = PDFDocument()
        let page = PDFPage()
        let tableWidth = page.bounds(for: .mediaBox).width - 2 * 50 // Subtracting the left and right margins
        let tableHeight: CGFloat = 20
        let tableRect = CGRect(x: 50, y: page.bounds(for: .mediaBox).height - 100 - CGFloat(expenses.count) * tableHeight, width: tableWidth, height: CGFloat(expenses.count) * tableHeight)
        
        
        // Add title at the top of the page
        let titleText = "Expense Report"
        let titleFont = UIFont.boldSystemFont(ofSize: 18)
        let titleRect = CGRect(x: 50, y: page.bounds(for: .mediaBox).height - 50, width: tableWidth, height: 40)
        let titleAnnotation = PDFAnnotation(bounds: titleRect, forType: .freeText, withProperties: nil)
        titleAnnotation.font = titleFont
        titleAnnotation.alignment = .center
        titleAnnotation.contents = titleText
        titleAnnotation.color = UIColor.white
        page.addAnnotation(titleAnnotation)

        newDocument.insert(page, at: 0)

        // Create table headers
        let headers = ["Amount", "Category", "Payment Type", "Expense Date"]
        let headerFont = UIFont.boldSystemFont(ofSize: 12)
        let headerCellWidth = tableWidth / CGFloat(headers.count)

        for (index, header) in headers.enumerated() {
            let headerCellRect = CGRect(x: tableRect.origin.x + CGFloat(index) * headerCellWidth, y: page.bounds(for: .mediaBox).height - 80, width: headerCellWidth, height: tableHeight)
            let headerAnnotation = PDFAnnotation(bounds: headerCellRect, forType: .freeText, withProperties: nil)
            headerAnnotation.font = headerFont
            headerAnnotation.alignment = .center
            headerAnnotation.contents = header
            headerAnnotation.color = UIColor.white
            page.addAnnotation(headerAnnotation)
        }

        // Add border to the table
        let tableBorderRect = CGRect(x: tableRect.origin.x, y: page.bounds(for: .mediaBox).height - 80, width: tableRect.width, height: 30)
        let tableBorderAnnotation = PDFAnnotation(bounds: tableBorderRect, forType: .square, withProperties: nil)
        tableBorderAnnotation.color = UIColor.black
        tableBorderAnnotation.border = PDFBorder()
        tableBorderAnnotation.border?.lineWidth = 1.0
        tableBorderAnnotation.border?.style = .solid
        page.addAnnotation(tableBorderAnnotation)

        

        var currentPageIndex = 0
        var currentRowIndex = expenses.count - 1 // Start from the last row

        while currentRowIndex >= 0 {
            let currentPage = newDocument.page(at: currentPageIndex)

            let expense = expenses[currentRowIndex]

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM yy"
            let expenseDateString = dateFormatter.string(from: expense.expenseDate)

            let rowData = ["\(expense.amount)", expense.category, expense.paymentType, expenseDateString]
            let rowFont = UIFont.systemFont(ofSize: 12)

            let rowCellWidth = tableWidth / CGFloat(rowData.count)

            for (index, data) in rowData.enumerated() {
                let rowCellRect = CGRect(x: tableRect.origin.x + CGFloat(index) * rowCellWidth, y: tableRect.origin.y + CGFloat(expenses.count - currentRowIndex + 1) * tableHeight - 40, width: rowCellWidth, height: tableHeight)
                let rowAnnotation = PDFAnnotation(bounds: rowCellRect, forType: .freeText, withProperties: nil)
                rowAnnotation.font = rowFont
                rowAnnotation.alignment = .center
                rowAnnotation.contents = data
                rowAnnotation.color = UIColor.white
                currentPage?.addAnnotation(rowAnnotation)
            }

            currentRowIndex -= 1

            // Check if the current page is full
            let availableHeight = page.bounds(for: .mediaBox).height - 250 - CGFloat(expenses.count + 1) * tableHeight
            if availableHeight < tableHeight {
                currentPageIndex += 1
                currentRowIndex = expenses.count - 1

                let newPage = PDFPage()
                newDocument.insert(newPage, at: newDocument.pageCount)
            }
        }

        pdfView.document = newDocument
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfView.frame = CGRect(x: 0, y: 60, width: view.bounds.width, height: view.bounds.height)
    }
}
