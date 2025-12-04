import SwiftUI
import AppKit
import Combine

// 1. The Main Entry Point
@main
struct MailGlance2App: App { // Renamed for your new project
    @StateObject private var mailFetcher = MailFetcher()
    
    var body: some Scene {
        MenuBarExtra("Mail Glance", systemImage: "envelope.badge") {
            VStack(alignment: .leading, spacing: 0) {
                Text("School & Home Inbox")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                Divider()
                
                if mailFetcher.isLoading {
                    Text("Syncing with Mail...")
                        .padding()
                } else if !mailFetcher.isMailRunning {
                    Button("Mail is closed. Click to Open.") {
                        mailFetcher.openMailApp()
                    }
                    .padding()
                } else if mailFetcher.emails.isEmpty {
                    Text("No messages found")
                        .padding()
                } else {
                    ForEach(mailFetcher.emails) { email in
                        Button(action: {
                            mailFetcher.openMailApp()
                        }) {
                            VStack(alignment: .leading) {
                                Text(email.sender)
                                    .font(.headline)
                                    .fontWeight(email.isRead ? .regular : .heavy)
                                Text(email.subject)
                                    .font(.caption)
                                    .fontWeight(email.isRead ? .regular : .bold)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }
                
                Divider()
                
                Button("Refresh") {
                    mailFetcher.fetchLatestEmails()
                }
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
            .onAppear {
                mailFetcher.fetchLatestEmails()
            }
        }
        .menuBarExtraStyle(.menu)
    }
}

// 2. The Data Model
struct EmailMessage: Identifiable {
    let id: Int
    let sender: String
    let subject: String
    let isRead: Bool
}

// 3. The Logic
class MailFetcher: ObservableObject {
    @Published var emails: [EmailMessage] = []
    @Published var isLoading = false
    @Published var isMailRunning = true
    
    private var timer: Timer?
    
    init() {
        fetchLatestEmails()
        // Auto-refresh every 60 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.fetchLatestEmails()
        }
    }
    
    func fetchLatestEmails() {
        let runningApps = NSWorkspace.shared.runningApplications
        let mailIsRunning = runningApps.contains { app in
            app.bundleIdentifier == "com.apple.mail"
        }
        
        DispatchQueue.main.async {
            self.isMailRunning = mailIsRunning
        }
        
        guard mailIsRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let scriptSource = """
            tell application "Mail"
                set output to ""
                set totalCount to count of messages of inbox
                
                if totalCount > 0 then
                    set fetchCount to 5
                    if totalCount < 5 then set fetchCount to totalCount
                    
                    set msgList to messages 1 thru fetchCount of inbox
                    repeat with aMsg in msgList
                        set theID to id of aMsg
                        set theSender to sender of aMsg
                        set theSubject to subject of aMsg
                        set isRead to read status of aMsg
                        set output to output & theID & "|||" & theSender & "|||" & theSubject & "|||" & isRead & "\n"
                    end repeat
                end if
                return output
            end tell
            """
            
            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: scriptSource) {
                let descriptor = scriptObject.executeAndReturnError(&error)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let result = descriptor.stringValue {
                        self.parseResults(result)
                    }
                }
            } else {
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }
    
    private func parseResults(_ rawText: String) {
        var newEmails: [EmailMessage] = []
        let lines = rawText.components(separatedBy: .newlines)
        
        for line in lines {
            let parts = line.components(separatedBy: "|||")
            if parts.count >= 4 {
                let idString = parts[0].trimmingCharacters(in: .whitespaces)
                let cleanSender = parts[1].trimmingCharacters(in: .whitespaces)
                let cleanSubject = parts[2].trimmingCharacters(in: .whitespaces)
                let isReadString = parts[3].trimmingCharacters(in: .whitespaces)
                
                let idValue = Int(idString) ?? 0
                let isRead = (isReadString == "true")
                
                if !cleanSender.isEmpty {
                    newEmails.append(EmailMessage(id: idValue, sender: cleanSender, subject: cleanSubject, isRead: isRead))
                }
            }
        }
        
        newEmails.sort { $0.id > $1.id }
        self.emails = newEmails
    }
    
    func openMailApp() {
        if let mailAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.mail") {
            let config = NSWorkspace.OpenConfiguration()
            config.activates = true
            NSWorkspace.shared.openApplication(at: mailAppURL, configuration: config, completionHandler: nil)
        }
    }
}
