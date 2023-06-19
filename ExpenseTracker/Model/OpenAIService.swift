//
//  OpenAIService.swift
//  ExpenseTracker
//
//  Created by Yangru Guo on 13/6/2023.
//

import Foundation
import Alamofire
import Combine
import NaturalLanguage

class OpenAIService{
    
    let baseURL = "https://api.openai.com/v1/"
    
    func prepareExpenseDataForAIService(userQuestion:String) -> String {
        let db = DBManager()
        let expense = db.read()
        let token_limit = 2000
        // Create an array to store the recent expense information
        var recentExpenseInfo: [String] = []

        // Calculate the token count of the context
        let tokenizer = NLTokenizer(unit: .word)
        var userQuestionTokensNumber:Int = 0
        tokenizer.string = userQuestion
        tokenizer.enumerateTokens(in: userQuestion.startIndex..<userQuestion.endIndex) { tokenRange, _ in
            userQuestionTokensNumber += 1
            return true
        }
        
        var contextTokenNumber:Int = 0

        // Extract the relevant information of the most recent expenses
        for expense in expense {
            let expenseInfo = "Date: \(expense.expenseDateString), Amount: \(expense.amount), Category: \(expense.category), Payment Type: \(expense.paymentType)"
            
            tokenizer.string = expenseInfo
            var expenseInfoTokenNumber:Int = 0
            tokenizer.enumerateTokens(in: expenseInfo.startIndex..<expenseInfo.endIndex) { tokenRange, _ in
                expenseInfoTokenNumber += 1
                return true
            }
            if contextTokenNumber + expenseInfoTokenNumber < token_limit - 1 {
                recentExpenseInfo.append(expenseInfo)
                contextTokenNumber += expenseInfoTokenNumber
            } else{
                break
            }
        }
        let recentExpensesContext = recentExpenseInfo.joined(separator: "\n")
        let context = "\(recentExpensesContext)\nUser Question: \(userQuestion)"
        return context
    }
    
    func sendMessage(message:String) -> AnyPublisher<OpenAICompletionsResponse,Error>{
        let body = OpenAICompletionsBody(model:"text-davinci-003",prompt:message,temperature:0.7,max_tokens: 256)
        let headers:HTTPHeaders = ["Authorization":"Bearer \(Constants.OPEN_AI_API_KEY)"]
        return Future {[weak self] promise in
            guard let self = self else{return}
            
            AF.request(self.baseURL + "completions", method: .post, parameters:body, encoder:.json, headers:headers).responseDecodable(of:OpenAICompletionsResponse.self) { response in

                switch response.result{
                case .success(let result):
                    promise(.success(result))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

struct OpenAICompletionsBody:Encodable{
    let model: String
    let prompt: String
    let temperature:Float?
    let max_tokens:Int
}

struct OpenAICompletionsResponse:Decodable {
    let id:String
    let choices:[OpenAICompetitionsChoice]
}

struct OpenAICompetitionsChoice:Decodable {
    let text:String
}
