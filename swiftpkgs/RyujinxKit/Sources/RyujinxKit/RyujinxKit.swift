import Foundation
import FrameworkHeaders

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
  DispatchQueue.main.async(execute: startCoreClr2)
}
public func startCoreClr2() {
  guard initHookMmap() else {
    print("mmap hook init failed!")
    return
  }
  // expand the top of stack; hope this works...
  let pthreadSelf = pthread_self()
  let stackCurrentTop = pthread_get_stackaddr_np(pthreadSelf)
  let stackCurrentSize = pthread_get_stacksize_np(pthreadSelf)
  let stackCurrentBottom = stackCurrentTop - stackCurrentSize
  let extraSize = 7 * 1024 * 1024
  let newMappedStack = mmap(
    stackCurrentBottom - extraSize, extraSize, PROT_READ | PROT_WRITE,
    MAP_ANONYMOUS | MAP_FIXED | MAP_PRIVATE, -1, 0)
  if newMappedStack == MAP_FAILED {
    print("can't expand the stack")
    return
  }
  // shut up SDL2
  SDL_SetMainReady()
  // Debugger crashes during init; turn it off
  setenv("DOTNET_EnableDiagnostics", "0", 1)
  // We need TRUSTED_PLATFORM_ASSEMBLIES since CoreCLR by default looks in the same directory as libcoreclr.dylib

  let resBase = Bundle.module.path(forResource: "res", ofType: nil)!
  let sdl2Path = Bundle.main.path(forResource: "Frameworks/SDL2.framework", ofType: nil)!
  // no, I don't know why PInvokeOverrideFn isn't imported as convention c
  // let pInvokeOverrideFnClosure: PInvokeOverrideFn = pInvokeOverride
  typealias PInvokeOverrideFnBetter = @convention(c) (UnsafePointer<CChar>?, UnsafePointer<CChar>?)
    -> UnsafeRawPointer?
  let pInvokeOverrideFnClosure: PInvokeOverrideFnBetter = pInvokeOverride
  let pInvokeOverrideAddr = unsafeBitCast(pInvokeOverrideFnClosure, to: UInt64.self)
  let pInvokeOverrideStr = "0x" + String(pInvokeOverrideAddr, radix: 16)

  let propertyKeys = [
    "TRUSTED_PLATFORM_ASSEMBLIES", "APP_PATHS", "NATIVE_DLL_SEARCH_DIRECTORIES", "PINVOKE_OVERRIDE",
  ]
  let propertyValues = [
    resBase + "/System.Private.CoreLib.dll", resBase, sdl2Path, pInvokeOverrideStr,
  ]
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
  let assemblyPath = resBase + "/Ryujinx.Headless.SDL2.dll"
  var exitCode: UInt32 = 0
  let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    .path
  let rootDirectory = documentDirectory + "/Ryujinx"
  let fileToRun = documentDirectory + "/hbmenu.nro"
  let ryujinxArgs = [
    "--enable-debug-logs", "true", "--enable-trace-logs", "true", "--memory-manager-mode",
    "SoftwarePageTable", "--graphics-backend", "Vulkan", fileToRun,
  ]
  var err2: Int32 = 0
  withArrayOfCStrings(ryujinxArgs) { ryujinxArgsRaw in
    var ryujinxArgsRaw = ryujinxArgsRaw.map({ UnsafePointer<CChar>($0) })
    ryujinxArgsRaw.withUnsafeMutableBufferPointer { ryujinxArgsRawMutable in

      err2 = coreclr_execute_assembly(
        coreclrHostHandle, coreclrDomainId, Int32(ryujinxArgs.count),
        ryujinxArgsRawMutable.baseAddress, assemblyPath, &exitCode)
    }
  }
  guard err2 == 0 else {
    print("coreclr_execute_assembly_ptr failed: \(err)")
    return
  }
}

var g_HookMmapReserved4GB: UnsafeMutableRawPointer! = nil
var g_HookMmapReserved1GB: UnsafeMutableRawPointer! = nil

func initHookMmap() -> Bool {
  g_HookMmapReserved4GB = mmap(
    nil, 0x1_0000_0000, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0)
  if g_HookMmapReserved4GB == nil {
    print("can't allocate 4gb")
    return false
  }
  g_HookMmapReserved1GB = mmap(
    nil, 0x4000_0000, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0)
  if g_HookMmapReserved1GB == nil {
    print("can't allocate 1gb")
    return false
  }
  return true
}

func hookMmap(
  addr: UnsafeMutableRawPointer?, len: Int, prot: Int32, flags: Int32, fd: Int32, offset: off_t
) -> UnsafeMutableRawPointer! {
  print("mmap hook!")
  // TODO(zhuowei): threads?
  if g_HookMmapReserved4GB != nil && len == 0x1_0000_0000 {
    let ret = g_HookMmapReserved4GB
    g_HookMmapReserved4GB = nil
    return ret
  }
  if g_HookMmapReserved1GB != nil && len == 0x7ff0_0000 {
    // hack: this returns only 1GB when it asks for 2GB!!
    let ret = g_HookMmapReserved1GB
    g_HookMmapReserved1GB = nil
    return ret
  }
  return mmap(addr, len, prot, flags, fd, offset)
}

func pInvokeOverride(libraryName: UnsafePointer<CChar>!, entrypointName: UnsafePointer<CChar>!)
  -> UnsafeRawPointer?
{
  let libraryName = String(cString: libraryName)
  let entrypointName = String(cString: entrypointName)
  // print(libraryName, entrypointName)
  if entrypointName == "mmap" {
    typealias MmapType = @convention(c) (
      _: UnsafeMutableRawPointer?, _: Int, _: Int32, _: Int32, _: Int32, _: off_t
    ) -> UnsafeMutableRawPointer?
    return unsafeBitCast(hookMmap as MmapType, to: UnsafeRawPointer.self)
  }
  return nil
}
