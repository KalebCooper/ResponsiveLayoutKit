# ResponsiveLayoutKit demo app

A standalone iOS app that exercises every ResponsiveLayoutKit API live. It references the package as a local dependency, so it never ships via SwiftPM and library consumers never build it.

## Why there is no `.xcodeproj` here

SwiftPM can't build an iOS `.app`, so the demo needs a real Xcode app target. The project is generated from [`project.yml`](project.yml) with [XcodeGen](https://github.com/yonaskolb/XcodeGen) instead of being checked in (`ResponsiveLayoutKitDemo.xcodeproj` is gitignored). After cloning, generate it yourself.

## Setup

```sh
# One-time: install XcodeGen (requires 2.46.0+)
brew install xcodegen

# Generate the project and open it
cd Demo && xcodegen generate
open ResponsiveLayoutKitDemo.xcodeproj
```

Pick an iPhone or iPad simulator and hit **Run** (⌘R). The scheme is `ResponsiveLayoutKitDemo`.

Re-run `xcodegen generate` whenever `project.yml` or the source layout under `Sources/`/`Resources/` changes.
