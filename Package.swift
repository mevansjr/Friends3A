// swift-tools-version:4.2
//
//  Friends3A.swift
//  Friends3A
//
//  Created by Mark Evans on 23/10/15.
//  Copyright © 2017 3Advance. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "Friends3A",
    products: [
        .library(
            name: "Friends3A",
            targets: ["Friends3A"]),
        ],
    dependencies: [],
    targets: [
        .target(
            name: "Friends3A",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "Friends3ATests",
            dependencies: ["Friends3A"],
            path: "Tests")
    ]
)
