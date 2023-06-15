//
//  ChatBotSwiftUIView.swift
//  ExpenseTracker
//
//  Created by Yangru Guo on 13/6/2023.
//

import SwiftUI
import Combine

struct ChatBotSwiftUIView: View {
    @State var chatMessages:[ChatMessage] = [ChatMessage(id: UUID().uuidString, content: "Hello, what can I do for you?", dateCreated: Date(), sender: .gpt)]
    @State var messageText:String = ""
    @State var cancellables = Set<AnyCancellable>()
    let openAIService = OpenAIService()
    var body: some View {
        VStack{
            ScrollView{
                LazyVStack{
                    ForEach(chatMessages,id:\.id) { message in
                        messageView(message:message)
                    }
                }
            }
            HStack{
                TextField("Enter a message", text: $messageText)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(12)
                Button{
                    sendMessage()
                } label:{
                    Text("Ask advisor")
                        .foregroundColor(.white)
                        .padding()
                        .background(.cyan)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }
    
    func messageView(message:ChatMessage) -> some View{
        HStack {
            if message.sender == .me{Spacer()}
            if message.sender == .gpt{
                Image(systemName: "face.dashed.fill")
                    .resizable()
                    .frame(width: 45,height:45)
                    .foregroundColor(.mint)
            }
            Text(message.content)
                .foregroundColor(message.sender == .gpt ? .white : .black)
                .padding()
                .background(message.sender == .gpt ? .mint : .gray.opacity(0.1))
                .cornerRadius(16)
            if message.sender == .gpt{
                Spacer()
            }
        }
    }

    func sendMessage(){
        print("buttonpressed")
        let myMessage = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .me)
        chatMessages.append(myMessage)
        openAIService.sendMessage(message:messageText).sink{ completion in
        } receiveValue: { response in
            guard let textResponse = response.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else {return}
            let gptMessage = ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .gpt)
            chatMessages.append(gptMessage)
        }
        .store(in: &cancellables)
        messageText = ""
    }
}

struct ChatBotSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ChatBotSwiftUIView()
    }
}

struct ChatMessage{
    let id:String
    let content:String
    let dateCreated:Date
    let sender:MessageSender
}

enum MessageSender{
    case me
    case gpt
}


