//
//  ContentView.swift
//  Simple Chat
//
//  Created by Shashikant's_Macmini on 13/07/20.
//  Copyright © 2020 redbytes. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @State var name = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.orange
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding(.top, 12)
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    if !name.isEmpty {
                        NavigationLink(destination: MsgPage(name: name)) {
                            HStack {
                                Text("Join")
                                Image(systemName: "arrow.right.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .frame(width: 100, height: 50)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .padding(.bottom, 15)
                    }
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding()
            }
            .edgesIgnoringSafeArea(.all)
        }
        .animation(.default)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK:- MsgPage
struct MsgPage: View {
    
    var name = ""
    @State var typeMsg = ""
    @ObservedObject var msg = observer()
    
    var body: some View {
        VStack{
            List(msg.msgs) { i in
                MsgRow(msg: i.msg, name: i.name, myMsg: i.name == self.name)
            }.navigationBarTitle("Chats", displayMode: .inline)
            HStack {
                TextField("Msg", text: $typeMsg)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    self.msg.addMsg(msg: self.typeMsg, name: self.name)
                    self.typeMsg = ""
                }) {
                    Text("Send")
                }.padding()
            }
            
        }
    }
}

struct MsgRow: View {
    var msg = ""
    var name = ""
    var myMsg = false
    
    var body: some View {
        HStack {
            if myMsg {
                Text(msg)
                    .padding(8)
                    .background(Color.green)
                    .cornerRadius(6)
                    .foregroundColor(.white)
                
                Spacer()
            } else {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(msg)
                        .padding(8)
                        .background(Color.red)
                        .cornerRadius(6)
                        .foregroundColor(.white)
                    Text(name)
                }
                
            }
        }
    }
}


// MARK:- Observers
class observer: ObservableObject {
    
    @Published var msgs = [datatype]()
    
    init() {
        let db = Firestore.firestore()
        db.collection("msgs").addSnapshotListener { (snap, err) in
            if err != nil {
                debugPrint(err?.localizedDescription ?? "")
                return
            } else {
                for i in snap!.documentChanges {
                    if i.type == .added {
                        guard
                            let name = i.document.get("name") as? String,
                            let msg = i.document.get("msg") as? String
                            else {
                                debugPrint("Error while fecting obj")
                                return
                        }
                        let id  = i.document.documentID
                        self.msgs.append(datatype(id: id, name: name, msg: msg))
                    }
                }
            }
        }
    }
    
    func addMsg(msg: String, name: String) {
        let db = Firestore.firestore()
        db.collection("msgs").addDocument(data: ["msg": msg, "name": name]) { err in
            if err != nil {
                debugPrint(err?.localizedDescription ?? "")
                return
            }
            debugPrint("Success")
        }
    }
    
}

// MARK:- Model
struct datatype: Identifiable {
    var id: String
    var name: String
    var msg: String
}
