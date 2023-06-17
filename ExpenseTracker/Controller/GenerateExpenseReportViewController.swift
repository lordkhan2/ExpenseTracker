import UIKit
import PDFKit

class GenerateExpenseReportViewController: UIViewController {
    
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    
    var fromDate: Date?
    var toDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goToPdfGenerate(_ sender: UIButton) {
        fromDate = fromDatePicker.date
        toDate = toDatePicker.date
        
        if let fromDate = fromDatePicker?.date, let toDate = toDatePicker?.date {
            if fromDate <= toDate {
                performSegue(withIdentifier: "pdfGenerationSegue", sender: self)
            } else {
                let alert = UIAlertController(title: "Invalid Date Range", message: "The 'From' date must be less than or equal to the 'To' date.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pdfGenerationSegue" {
            if let destinationVC = segue.destination as? GenerateExpenseWithDateViewController {
                destinationVC.fromDate = fromDate
                destinationVC.toDate = toDate
            }
        }
    }
}
