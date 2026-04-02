// StoryFormat.swift
// Format enum for interactive fiction story files and packages.
//
// Copyright (c) 2026 Andy Volk (https://andyvolk.com)
// SPDX-License-Identifier: MIT

/// The detected format of an interactive fiction story file or package.
@frozen
public enum StoryFormat: String, Codable, Hashable, Sendable, CaseIterable {
    /// Z-machine (Infocom/Inform): .z1 through .z8, .zblorb
    case zcode
    /// Glulx (Inform 7+): .ulx, .gblorb
    case glulx
    /// Generic Blorb container when only the `.blorb` extension is known.
    case blorb
    /// Hugo: .hex, .hdx
    case hugo
    /// Alan: .acd
    case alan
    /// ADRIFT: .taf
    case adrift
    /// TADS 2: .gam
    case tads2
    /// TADS 3: .t3
    case tads3
    /// Adventuron: .aastory
    case adventuron
    /// Browser-playable interactive fiction package: .html, .htm
    case web
    /// Twine source or project file: .twee, .tw2, .tw3
    case twineSource
}
