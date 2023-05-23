//
//  ContentView.swift
//  WordScramble
//
//  Created by Kaviraj Pandey on 22/05/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    //@State private var backgroundColor = LinearGradient(colors: [.blue, .white], startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.none)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        ZStack {
                            Color.mint
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        
                    }
                }
                
                Section {
                    Text("Score: \(score)")
                        .font(.headline)
                }
                
            }
            .navigationTitle(rootWord)
        }
        .onSubmit(addNewWord)
        // this is a dedicated viewModifier for running a closure when a view is shown
        .onAppear(perform: startGame)
        .alert(errorTitle, isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Refresh Word") {
                    startGame()
                    score = 0
                    usedWords.removeAll()
                }
            }
        }
    }
    
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // disallow answer less than 3 letters
        guard answer.count > 2 else { return }
        guard answer != rootWord else { return }
        // Word used or not before
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", msg: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", msg: "You can't spell that word from \(rootWord)")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", msg: "This word doesn't contain in english")
            return
        }
        
        
        
        
        
        
        
        
        // below code we are insertng our wrote text in a list so here we can do little sort of animation
        withAnimation {
            usedWords.insert(answer, at: 0)
            score += 1
        }
        
        newWord = ""
    }
    
    func startGame() {
        //Find the URL for start.txt in our app bundle
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsUrl) {
                let allWords = startWords.components(separatedBy: "\n")
                //Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "helloworld"
                // if we reach here we are good to go
                return
            }
        }
        //If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Sorry can't load start.txt from bundle")
    }
    
    // Usedwords doesn't contain this word so add otherwise return false
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    // check for a random word can be made of a random word
    
    func isPossible(word: String) -> Bool {
        // first store locally your root word in a variable
        var tempWord = rootWord
        // looping over our word
        for letter in word {
            // this checks letter exists in our copy
            if let pos = tempWord.firstIndex(of: letter) {
                // if that words exists remove that word from our tempword
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    // check for misspelled word
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    // check for errors
    func wordError(title: String, msg: String) {
        errorTitle = title
        errorMessage = msg
        showingError = true
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
