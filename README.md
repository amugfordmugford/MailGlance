Mail Glance ✉️

A lightweight macOS menu bar application that provides a quick, read-only view of your latest Apple Mail messages.

No more getting distracted by your full inbox just to check if the school sent an email.

🚀 Why I Built This

As a parent, I needed a way to keep an eye on important incoming emails (like updates from my kids' schools) without having to keep the main Mail app window open and constantly staring at my entire inbox.

This tool sits quietly in the menu bar, fetching the latest 5 emails every minute. It lets me see Sender and Subject at a glance, distinguishing between Read (normal text) and Unread (bold text).

✨ Features

Menu Bar Resident: Runs silently in the background with a discreet envelope icon.

Live Sync: Auto-refreshes every 60 seconds.

Read Status: Instantly see which emails are unread (Bold) vs. read (Normal).

Privacy Focused: Uses local AppleScript to talk directly to your Mail app. No data is ever sent to the cloud or third-party servers.

One-Click Access: Clicking a message brings the actual Apple Mail app to the front.

🛠 Tech Stack

Swift 5 & SwiftUI

AppleScript (for communicating with the local Mail database)

Combine (for reactive UI updates)

⚙️ Installation & Setup

Since this app uses AppleScript to control another application, it requires specific permissions that prevent it from being a standard sandboxed app.

Prerequisites

macOS (Ventura or newer recommended)

Xcode 14+

Apple Mail app (must be configured and running)

Building from Source

Clone this repository.

Open the project in Xcode.

Critical Security Settings:

Click on the Project target.

Go to Signing & Capabilities.

Remove "App Sandbox": Click the trash can icon next to App Sandbox. This is required because the app uses AppleScript to read your local mail data.

Remove "Hardened Runtime": If present, remove this as well.

Hide Dock Icon:

In Info.plist, ensure Application is agent (UIElement) is set to YES.

Build & Run (Cmd + R).

First Run Permissions

When you first launch the app, macOS will prompt you:

"MailAppToolBarReadApp" wants access to control "Mail".

You must click OK. If you accidentally deny this, the app will show "Permission Denied."

⚠️ Troubleshooting

The app says "No messages or Permission denied"

Ensure the Apple Mail app is actually running (it can be minimized/hidden, but must be open).

Check your Privacy settings:

Go to System Settings > Privacy & Security > Automation.

Expand the list under your app name and ensure Mail is toggled ON.

I click the menu bar icon but nothing happens
This usually means the app is running as a standard windowed app rather than an agent.

Check your Info.plist.

Add key: Application is agent (UIElement) -> Value: YES.

Resetting Permissions
If permissions are stuck, run this in Terminal:

tccutil reset AppleEvents


📝 License

This project is open source and available under the MIT License.

Note: This app is a local tool and is not affiliated with Apple Inc.
