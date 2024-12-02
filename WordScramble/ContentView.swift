//
//  ContentView.swift
//  WordScramble
//
//  Created by Richárd Pohner on 02.12.24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords: [String] = [String]()
    @State private var rootWord: String = ""
    @State private var newWord: String = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    @State private var score:Int = 0
    
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .toolbar {
                                    ToolbarItem(placement: .bottomBar) {
                                        Button("Restart Game") {
                                            restartGame()
                                        }
                                    }
                                }
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        
                        
                    }
                }
                Section {
                    Text("Score: \(score)")
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showError) {
                Button("OK"){}
            } message: {
                Text(errorMessage)
            }
        }

    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        // extra validation to come
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more Original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        
        
        //Both of the are good but the second one is better. Because new words will appear in the beginning
        //usedWords.append(answer)
        if answer.count > 3 && answer != rootWord{
            withAnimation{
                usedWords.insert(answer, at: 0)
                score += answer.count
            }
        } else {
            wordError(title: "Word too short or you entered the same word as the root", message: "Word has to be at least 4 characters long")
        }
        
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .ascii) {
                let allwords =  startWords.components(separatedBy: "\n")
                rootWord = allwords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Couldn't load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempword = rootWord
        
        for letter in word {
            if let pos = tempword.firstIndex(of: letter) {
                tempword.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
        
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showError = true
    }
    
    func restartGame() {
        score = 0
        usedWords.removeAll()
        startGame()
    }
}

#Preview {
    ContentView()
}
