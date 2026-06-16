// Copyright 2025-present 650 Industries. All rights reserved.

import ExpoModulesCore

/// An unhandled JavaScript error forwarded from the JS-side `global.ErrorUtils` handler. Recorded as
/// an `exception` log event following OpenTelemetry's exception conventions.
@Record
struct ErrorReport {
  var source: Source = .global
  var type: String?
  var message: String = ""
  var stacktrace: String?
  var isFatal: Bool = false

  /// How the error was captured. A closed set so the `expo.error.source` attribute stays consistent.
  enum Source: String, Enumerable {
    case global
  }

  /// Builds the `exception` log event. Following OpenTelemetry's exception-in-logs convention, the
  /// error rides as `exception.*` attributes (the event name is `exception` because this captures
  /// errors from a handler, not a specific operation). `expo.error.*` carries the bits OTel has no
  /// field for: the capture source and whether the error was fatal. Fatal errors log at `fatal`
  /// severity, the rest at `error`.
  func toLogRecord() -> LogRecord {
    var attributes: [String: Any] = [
      "expo.error.source": source.rawValue,
      "expo.error.is_fatal": isFatal,
    ]
    attributes["exception.type"] = type
    attributes["exception.message"] = message
    attributes["exception.stacktrace"] = stacktrace
    return LogRecord(
      name: "exception",
      attributes: attributes,
      severity: isFatal ? .fatal : .error
    )
  }
}
