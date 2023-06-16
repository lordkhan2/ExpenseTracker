import UIKit
import PDFKit

class GenerateExpenseReportViewController: UIViewController {
    var db = DBManager()
    var expenses = Array<Expense>()
    var pdfDocument: PDFDocument?
    let pdfView = PDFView()
    let downloadButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfView)
        view.addSubview(downloadButton)

        // Set up the button
        downloadButton.setTitle("Download PDF", for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)

        expenses = db.read()

        let newDocument = generateExpenseReportDocument()

        // Set the generated document as the PDFView's document
        pdfDocument = newDocument
        pdfView.document = newDocument
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfView.frame = CGRect(x: 0, y: 60, width: view.bounds.width, height: view.bounds.height)

        // Position the download button at the bottom center of the view
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 40
        downloadButton.frame = CGRect(x: (view.bounds.width - buttonWidth) / 2, y: view.bounds.height - 150, width: buttonWidth, height: buttonHeight)
    }

    @objc func downloadButtonTapped() {
        guard let document = pdfDocument else {
            print("PDF document not found.")
            return
        }

        // Generate the PDF data
        guard let pdfData = document.dataRepresentation() else {
            print("Failed to generate PDF data.")
            return
        }

        // Save PDF data to file
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let filePath = temporaryDirectory.appendingPathComponent("expense_report.pdf")

        do {
            try pdfData.write(to: filePath)
            print("PDF saved to: \(filePath)")

            // Present an activity view controller to share or open the PDF file
            let activityViewController = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        } catch {
            print("Failed to save PDF: \(error)")
        }
    }

    func generateExpenseReportDocument() -> PDFDocument {
        let newDocument = PDFDocument()
        
        // Generate the expense report PDF content here
        let page = PDFPage()
        let tableWidth = page.bounds(for: .mediaBox).width - 2 * 50 // Subtracting the left and right margins
        let tableHeight: CGFloat = 20
        let tableRect = CGRect(x: 50, y: page.bounds(for: .mediaBox).height - 100 - CGFloat(expenses.count) * tableHeight, width: tableWidth, height: CGFloat(expenses.count) * tableHeight)
        
            
            
         //Add title at the top of the page
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

        newDocument.insert(page, at: 0)
        
        return newDocument
    }
}


