//
//  ReceiptRegrexHandler.swift
//  ExpenseTracker
//
//  Created by Yangru Guo on 7/6/2023.
//

import Foundation

struct ReceiptRegexHandler{
    let TARGET_DATE_TYPE = "d MMM yyyy"
    var expenseDate:String?
    var amount:String?
    var paymentType:String?
    
    mutating func recordRecognizedInformation(sourceString:String){
        //Recognise and save date information
        let dateRegex = #"(\d{1,2}/\d{1,2}/\d{2,4})|(\d{1,2}-\d{1,2}-\d{2,4})|(\d{1,2}\s[a-zA-Z]{3,9}\s\d{2,4})|(([a-zA-Z]{3,9})\s+(\d{1,2}),\s+(\d{2,4}))"# // Regular expression pattern for common date formats: "MM/DD/YYYY", "M/D/YY", "MM-DD-YYYY", "M-D-YY", "DD Month YYYY", etc.

        let regex = try? NSRegularExpression(pattern: dateRegex, options: .caseInsensitive)
        let matches = regex?.matches(in: sourceString, options: [], range: NSRange(sourceString.startIndex..., in: sourceString))

        matches?.forEach { match in
            if let range = Range(match.range, in: sourceString) {
                identifyReceiptDate(String(sourceString[range]))
            }
        }
        
        //recognise amount
        let amountRegex = #"\b\d+\.\d{2}\b"# // Regular expression pattern for common payment amount formats: digits with optional decimal places
        let regexAmount = try? NSRegularExpression(pattern: amountRegex, options: .caseInsensitive)
        let amountMatches = regexAmount?.matches(in: sourceString, options: [], range: NSRange(sourceString.startIndex..., in: sourceString))

        amountMatches?.forEach { amountMatch in
            if let range = Range(amountMatch.range, in: sourceString) {
                let amount = String(sourceString[range])
                if let currentAmount = self.amount{
                    if Double(currentAmount)! < Double(amount)! {
                        self.amount = amount
                    }
                } else{
                    self.amount = amount
                }
            }
        }

    }
    
    mutating func identifyReceiptDate(_ dateString: String){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_AU") // Set the locale based on your requirements
        dateFormatter.timeZone = TimeZone.current // Set the timezone based on your requirements
        
        let formats = [
            "dd/MM/yy",
            "dd/MM/yyyy",
            "dd-MM-yy",
            "dd-MM-yyyy",
            "dd-MMM-yyyy",
            "MMM d,yy",
            "MMM dd, yyyy",
            "M/D/YY",
            "MM-DD-YYYY",
            "M-D-YY",
            "DD Month YYYY"
            // Add more date formats as needed
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                dateFormatter.dateFormat = TARGET_DATE_TYPE
                self.expenseDate = dateFormatter.string(from: date)
                break
            }
        }
    }

}
