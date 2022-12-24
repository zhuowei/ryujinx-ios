import Foundation
import RyujinxFramework

var coreclrHostHandle: UnsafeMutableRawPointer?
var coreclrDomainId: UInt32 = 0

// from Swift stdlib
// https://github.com/apple/swift/blob/7123d2614b5f222d03b3762cb110d27a9dd98e24/stdlib/private/SwiftPrivate/SwiftPrivate.swift#L60

/// Compute the prefix sum of `seq`.
public func scan<
  S: Sequence, U
>(_ seq: S, _ initial: U, _ combine: (U, S.Element) -> U) -> [U] {
  var result: [U] = []
  result.reserveCapacity(seq.underestimatedCount)
  var runningResult = initial
  for element in seq {
    runningResult = combine(runningResult, element)
    result.append(runningResult)
  }
  return result
}

public func withArrayOfCStrings<R>(
  _ args: [String], _ body: ([UnsafeMutablePointer<CChar>?]) -> R
) -> R {
  let argsCounts = Array(args.map { $0.utf8.count + 1 })
  let argsOffsets = [0] + scan(argsCounts, 0, +)
  let argsBufferSize = argsOffsets.last!

  var argsBuffer: [UInt8] = []
  argsBuffer.reserveCapacity(argsBufferSize)
  for arg in args {
    argsBuffer.append(contentsOf: arg.utf8)
    argsBuffer.append(0)
  }

  return argsBuffer.withUnsafeMutableBufferPointer {
    (argsBuffer) in
    let ptr = UnsafeMutableRawPointer(argsBuffer.baseAddress!).bindMemory(
      to: CChar.self, capacity: argsBuffer.count)
    var cStrings: [UnsafeMutablePointer<CChar>?] = argsOffsets.map { ptr + $0 }
    cStrings[cStrings.count - 1] = nil
    return body(cStrings)
  }
}

public func startCoreClr() {
  // We need TRUSTED_PLATFORM_ASSEMBLIES since CoreCLR by default looks in the same directory as libcoreclr.dylib
  let propertyKeys = ["TRUSTED_PLATFORM_ASSEMBLIES", "APP_PATHS"]
  let resBase = Bundle.module.path(forResource: "res", ofType: nil)!
  let propertyValues = [resBase + "/System.Private.CoreLib.dll", resBase]
  var err: Int32 = 0
  withArrayOfCStrings(propertyKeys) { propertyKeysRaw in
    var propertyKeysRaw = propertyKeysRaw.map({ UnsafePointer<CChar>($0) })
    withArrayOfCStrings(propertyValues) { propertyValuesRaw in
      var propertyValuesRaw = propertyValuesRaw.map({ UnsafePointer<CChar>($0) })
      propertyKeysRaw.withUnsafeMutableBufferPointer { propertyKeysRawMutable in
        propertyValuesRaw.withUnsafeMutableBufferPointer { propertyValuesRawMutable in
          err = coreclr_initialize(
            Bundle.main.executablePath, "RyujinxApp", Int32(propertyKeys.count),
            propertyKeysRawMutable.baseAddress, propertyValuesRawMutable.baseAddress,
            &coreclrHostHandle, &coreclrDomainId)
        }
      }

    }
  }

  guard err == 0 else {
    print("coreclr_initialize failed: \(err)")
    return
  }
  // (hacker voice) I'm in
  let assemblyPath = resBase + "/helloworldpls.dll"
  var exitCode: UInt32 = 0
  let err2 = coreclr_execute_assembly(
    coreclrHostHandle, coreclrDomainId, 0, nil, assemblyPath, &exitCode)
  guard err2 == 0 else {
    print("coreclr_execute_assembly_ptr failed: \(err)")
    return
  }
}
