// swift-tools-version: 5.9
// Package.swift
// Swift package manifest for StoryFormatDetector.
//
// Copyright (c) 2026 Andy Volk (https://andyvolk.com)
// SPDX-License-Identifier: MIT

import PackageDescription

let package = Package(
    name: "StoryFormatDetector",
    platforms: [.iOS(.v13), .macOS(.v10_15), .visionOS(.v1)],
    products: [
        .library(name: "StoryFormatDetector", targets: ["StoryFormatDetector"]),
    ],
    targets: [
        .target(name: "StoryFormatDetector"),
        .testTarget(
            name: "StoryFormatDetectorTests",
            dependencies: ["StoryFormatDetector"]
        ),
    ]
)
