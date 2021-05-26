# CTemplar (for iOS and iPadOS)

Official iOS and iPadOS client for the CTemplar secure (end-to-end encrypted) email service.

## Build Requirements

+ Xcode 11
+ iOS 13 SDK or later
+ Key-chain sharing
+ CocoaPods

## Runtime Requirements

+ iOS 13 or later

## Installation

Just run 'pod install' command in the terminal from the application source folder to install all need libraries. If 'pod  install' doesn't work then please try to running  'pod install --repo-update' first.

## Run

Run Ctemplar.xcworkspace

## Security

CTemplar uses a custom wrapper written in Swift around the well-known [GopenPGP](https://gopenpgp.org/) library.

