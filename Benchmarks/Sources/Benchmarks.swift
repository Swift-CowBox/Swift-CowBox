//
//  Copyright 2024 North Bronson Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Benchmark
import Collections
import CowBox

//  https://jaredkhan.com/blog/swift-copy-on-write#many-structs

//  https://github.com/apple/swift-collections/pull/31

//  https://github.com/ordo-one/package-benchmark

struct StructElement: Hashable {
  // A struct with about 80 bytes
  let a: Int64
  let b: Int64
  let c: Int64
  let d: Int64
  let e: Int64
  let f: Int64
  let g: Int64
  let h: Int64
  let i: Int64
  let j: Int64
}

extension StructElement {
  init(_ value: Int) {
    self.init(
      a: Int64(value),
      b: Int64(value),
      c: Int64(value),
      d: Int64(value),
      e: Int64(value),
      f: Int64(value),
      g: Int64(value),
      h: Int64(value),
      i: Int64(value),
      j: Int64(value)
    )
  }
}

@CowBox struct CowBoxElement: Hashable {
  @CowBoxNonMutating var a: Int64
  @CowBoxNonMutating var b: Int64
  @CowBoxNonMutating var c: Int64
  @CowBoxNonMutating var d: Int64
  @CowBoxNonMutating var e: Int64
  @CowBoxNonMutating var f: Int64
  @CowBoxNonMutating var g: Int64
  @CowBoxNonMutating var h: Int64
  @CowBoxNonMutating var i: Int64
  @CowBoxNonMutating var j: Int64
}

extension CowBoxElement {
  init(_ value: Int) {
    self.init(
      a: Int64(value),
      b: Int64(value),
      c: Int64(value),
      d: Int64(value),
      e: Int64(value),
      f: Int64(value),
      g: Int64(value),
      h: Int64(value),
      i: Int64(value),
      j: Int64(value)
    )
  }
}

func ArrayCowBoxElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var array = Array<CowBoxElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      CowBoxElement(i)
    )
  }
  benchmark.stopMeasurement()
  precondition(array.count == size)
  blackHole(array)
}

func ArrayCowBoxElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var array = Array<CowBoxElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      CowBoxElement(i)
    )
  }
  benchmark.startMeasurement()
  var copy = array
  copy.append(
    CowBoxElement(size)
  )
  benchmark.stopMeasurement()
  precondition(array.count == size)
  precondition(copy.count == size + 1)
  blackHole(array)
  blackHole(copy)
}

func ArrayCowBoxElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var array = Array<CowBoxElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      CowBoxElement(i)
    )
  }
  var copy = Array<CowBoxElement>()
  copy.reserveCapacity(size)
  for element in array {
    copy.append(element)
  }
  benchmark.startMeasurement()
  let equal = (array == copy)
  benchmark.stopMeasurement()
  precondition(array.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(array)
  blackHole(copy)
  blackHole(equal)
}

func ArrayStructElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var array = Array<StructElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      StructElement(i)
    )
  }
  benchmark.stopMeasurement()
  precondition(array.count == size)
  blackHole(array)
}

func ArrayStructElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var array = Array<StructElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      StructElement(i)
    )
  }
  benchmark.startMeasurement()
  var copy = array
  copy.append(
    StructElement(size)
  )
  benchmark.stopMeasurement()
  precondition(array.count == size)
  precondition(copy.count == size + 1)
  blackHole(array)
  blackHole(copy)
}

func ArrayStructElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var array = Array<StructElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      StructElement(i)
    )
  }
  var copy = Array<StructElement>()
  copy.reserveCapacity(size)
  for element in array {
    copy.append(element)
  }
  benchmark.startMeasurement()
  let equal = (array == copy)
  benchmark.stopMeasurement()
  precondition(array.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(array)
  blackHole(copy)
  blackHole(equal)
}

func ContiguousArrayCowBoxElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var array = ContiguousArray<CowBoxElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      CowBoxElement(i)
    )
  }
  benchmark.stopMeasurement()
  precondition(array.count == size)
  blackHole(array)
}

func ContiguousArrayCowBoxElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var array = ContiguousArray<CowBoxElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      CowBoxElement(i)
    )
  }
  benchmark.startMeasurement()
  var copy = array
  copy.append(
    CowBoxElement(size)
  )
  benchmark.stopMeasurement()
  precondition(array.count == size)
  precondition(copy.count == size + 1)
  blackHole(array)
  blackHole(copy)
}

func ContiguousArrayCowBoxElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var array = ContiguousArray<CowBoxElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      CowBoxElement(i)
    )
  }
  var copy = ContiguousArray<CowBoxElement>()
  copy.reserveCapacity(size)
  for element in array {
    copy.append(element)
  }
  benchmark.startMeasurement()
  let equal = (array == copy)
  benchmark.stopMeasurement()
  precondition(array.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(array)
  blackHole(copy)
  blackHole(equal)
}

func ContiguousArrayStructElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var array = ContiguousArray<StructElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      StructElement(i)
    )
  }
  benchmark.stopMeasurement()
  precondition(array.count == size)
  blackHole(array)
}

func ContiguousArrayStructElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var array = ContiguousArray<StructElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      StructElement(i)
    )
  }
  benchmark.startMeasurement()
  var copy = array
  copy.append(
    StructElement(size)
  )
  benchmark.stopMeasurement()
  precondition(array.count == size)
  precondition(copy.count == size + 1)
  blackHole(array)
  blackHole(copy)
}

func ContiguousArrayStructElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var array = ContiguousArray<StructElement>()
  array.reserveCapacity(size)
  for i in (0..<size) {
    array.append(
      StructElement(i)
    )
  }
  var copy = ContiguousArray<StructElement>()
  copy.reserveCapacity(size)
  for element in array {
    copy.append(element)
  }
  benchmark.startMeasurement()
  let equal = (array == copy)
  benchmark.stopMeasurement()
  precondition(array.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(array)
  blackHole(copy)
  blackHole(equal)
}

func DictionaryKeysCowBoxElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var dictionary = Dictionary<CowBoxElement, Int64>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[CowBoxElement(i)] = Int64(i)
  }
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  blackHole(dictionary)
}

func DictionaryKeysCowBoxElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = Dictionary<CowBoxElement, Int64>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[CowBoxElement(i)] = Int64(i)
  }
  benchmark.startMeasurement()
  var copy = dictionary
  copy[CowBoxElement(size)] = Int64(size)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size + 1)
  blackHole(dictionary)
  blackHole(copy)
}

func DictionaryKeysCowBoxElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = Dictionary<CowBoxElement, Int64>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[CowBoxElement(i)] = Int64(i)
  }
  var copy = Dictionary<CowBoxElement, Int64>()
  copy.reserveCapacity(size)
  for (key, value) in dictionary {
    copy[key] = value
  }
  benchmark.startMeasurement()
  let equal = (dictionary == copy)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(dictionary)
  blackHole(copy)
  blackHole(equal)
}

func DictionaryKeysStructElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var dictionary = Dictionary<StructElement, Int64>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[StructElement(i)] = Int64(i)
  }
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  blackHole(dictionary)
}

func DictionaryKeysStructElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = Dictionary<StructElement, Int64>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[StructElement(i)] = Int64(i)
  }
  benchmark.startMeasurement()
  var copy = dictionary
  copy[StructElement(size)] = Int64(size)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size + 1)
  blackHole(dictionary)
  blackHole(copy)
}

func DictionaryKeysStructElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = Dictionary<StructElement, Int64>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[StructElement(i)] = Int64(i)
  }
  var copy = Dictionary<StructElement, Int64>()
  copy.reserveCapacity(size)
  for (key, value) in dictionary {
    copy[key] = value
  }
  benchmark.startMeasurement()
  let equal = (dictionary == copy)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(dictionary)
  blackHole(copy)
  blackHole(equal)
}

func DictionaryValuesCowBoxElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var dictionary = Dictionary<Int64, CowBoxElement>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[Int64(i)] = CowBoxElement(i)
  }
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  blackHole(dictionary)
}

func DictionaryValuesCowBoxElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = Dictionary<Int64, CowBoxElement>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[Int64(i)] = CowBoxElement(i)
  }
  benchmark.startMeasurement()
  var copy = dictionary
  copy[Int64(size)] = CowBoxElement(size)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size + 1)
  blackHole(dictionary)
  blackHole(copy)
}

func DictionaryValuesCowBoxElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = Dictionary<Int64, CowBoxElement>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[Int64(i)] = CowBoxElement(i)
  }
  var copy = Dictionary<Int64, CowBoxElement>()
  copy.reserveCapacity(size)
  for (key, value) in dictionary {
    copy[key] = value
  }
  benchmark.startMeasurement()
  let equal = (dictionary == copy)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(dictionary)
  blackHole(copy)
  blackHole(equal)
}

func DictionaryValuesStructElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var dictionary = Dictionary<Int64, StructElement>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[Int64(i)] = StructElement(i)
  }
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  blackHole(dictionary)
}

func DictionaryValuesStructElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = Dictionary<Int64, StructElement>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[Int64(i)] = StructElement(i)
  }
  benchmark.startMeasurement()
  var copy = dictionary
  copy[Int64(size)] = StructElement(size)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size + 1)
  blackHole(dictionary)
  blackHole(copy)
}

func DictionaryValuesStructElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = Dictionary<Int64, StructElement>()
  dictionary.reserveCapacity(size)
  for i in (0..<size) {
    dictionary[Int64(i)] = StructElement(i)
  }
  var copy = Dictionary<Int64, StructElement>()
  copy.reserveCapacity(size)
  for (key, value) in dictionary {
    copy[key] = value
  }
  benchmark.startMeasurement()
  let equal = (dictionary == copy)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(dictionary)
  blackHole(copy)
  blackHole(equal)
}

func SetCowBoxElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var set = Set<CowBoxElement>()
  set.reserveCapacity(size)
  for i in (0..<size) {
    set.insert(
      CowBoxElement(i)
    )
  }
  benchmark.stopMeasurement()
  precondition(set.count == size)
  blackHole(set)
}

func SetCowBoxElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var set = Set<CowBoxElement>()
  set.reserveCapacity(size)
  for i in (0..<size) {
    set.insert(
      CowBoxElement(i)
    )
  }
  benchmark.startMeasurement()
  var copy = set
  copy.insert(
    CowBoxElement(size)
  )
  benchmark.stopMeasurement()
  precondition(set.count == size)
  precondition(copy.count == size + 1)
  blackHole(set)
  blackHole(copy)
}

func SetCowBoxElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var set = Set<CowBoxElement>()
  set.reserveCapacity(size)
  for i in (0..<size) {
    set.insert(
      CowBoxElement(i)
    )
  }
  var copy = Set<CowBoxElement>()
  copy.reserveCapacity(size)
  for element in set {
    copy.insert(element)
  }
  benchmark.startMeasurement()
  let equal = (set == copy)
  benchmark.stopMeasurement()
  precondition(set.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(set)
  blackHole(copy)
  blackHole(equal)
}

func SetStructElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var set = Set<StructElement>()
  set.reserveCapacity(size)
  for i in (0..<size) {
    set.insert(
      StructElement(i)
    )
  }
  benchmark.stopMeasurement()
  precondition(set.count == size)
  blackHole(set)
}

func SetStructElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var set = Set<StructElement>()
  set.reserveCapacity(size)
  for i in (0..<size) {
    set.insert(
      StructElement(i)
    )
  }
  benchmark.startMeasurement()
  var copy = set
  copy.insert(
    StructElement(size)
  )
  benchmark.stopMeasurement()
  precondition(set.count == size)
  precondition(copy.count == size + 1)
  blackHole(set)
  blackHole(copy)
}

func SetStructElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var set = Set<StructElement>()
  set.reserveCapacity(size)
  for i in (0..<size) {
    set.insert(
      StructElement(i)
    )
  }
  var copy = Set<StructElement>()
  copy.reserveCapacity(size)
  for element in set {
    copy.insert(element)
  }
  benchmark.startMeasurement()
  let equal = (set == copy)
  benchmark.stopMeasurement()
  precondition(set.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(set)
  blackHole(copy)
  blackHole(equal)
}

func TreeDictionaryKeysCowBoxElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var dictionary = TreeDictionary<CowBoxElement, Int64>()
  for i in (0..<size) {
    dictionary[CowBoxElement(i)] = Int64(i)
  }
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  blackHole(dictionary)
}

func TreeDictionaryKeysCowBoxElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = TreeDictionary<CowBoxElement, Int64>()
  for i in (0..<size) {
    dictionary[CowBoxElement(i)] = Int64(i)
  }
  benchmark.startMeasurement()
  var copy = dictionary
  copy[CowBoxElement(size)] = Int64(size)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size + 1)
  blackHole(dictionary)
  blackHole(copy)
}

func TreeDictionaryKeysCowBoxElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = TreeDictionary<CowBoxElement, Int64>()
  for i in (0..<size) {
    dictionary[CowBoxElement(i)] = Int64(i)
  }
  var copy = TreeDictionary<CowBoxElement, Int64>()
  for (key, value) in dictionary {
    copy[key] = value
  }
  benchmark.startMeasurement()
  let equal = (dictionary == copy)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(dictionary)
  blackHole(copy)
  blackHole(equal)
}

func TreeDictionaryKeysStructElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var dictionary = TreeDictionary<StructElement, Int64>()
  for i in (0..<size) {
    dictionary[StructElement(i)] = Int64(i)
  }
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  blackHole(dictionary)
}

func TreeDictionaryKeysStructElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = TreeDictionary<StructElement, Int64>()
  for i in (0..<size) {
    dictionary[StructElement(i)] = Int64(i)
  }
  benchmark.startMeasurement()
  var copy = dictionary
  copy[StructElement(size)] = Int64(size)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size + 1)
  blackHole(dictionary)
  blackHole(copy)
}

func TreeDictionaryKeysStructElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = TreeDictionary<StructElement, Int64>()
  for i in (0..<size) {
    dictionary[StructElement(i)] = Int64(i)
  }
  var copy = TreeDictionary<StructElement, Int64>()
  for (key, value) in dictionary {
    copy[key] = value
  }
  benchmark.startMeasurement()
  let equal = (dictionary == copy)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(dictionary)
  blackHole(copy)
  blackHole(equal)
}

func TreeDictionaryValuesCowBoxElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var dictionary = TreeDictionary<Int64, CowBoxElement>()
  for i in (0..<size) {
    dictionary[Int64(i)] = CowBoxElement(i)
  }
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  blackHole(dictionary)
}

func TreeDictionaryValuesCowBoxElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = TreeDictionary<Int64, CowBoxElement>()
  for i in (0..<size) {
    dictionary[Int64(i)] = CowBoxElement(i)
  }
  benchmark.startMeasurement()
  var copy = dictionary
  copy[Int64(size)] = CowBoxElement(size)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size + 1)
  blackHole(dictionary)
  blackHole(copy)
}

func TreeDictionaryValuesCowBoxElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = TreeDictionary<Int64, CowBoxElement>()
  for i in (0..<size) {
    dictionary[Int64(i)] = CowBoxElement(i)
  }
  var copy = TreeDictionary<Int64, CowBoxElement>()
  for (key, value) in dictionary {
    copy[key] = value
  }
  benchmark.startMeasurement()
  let equal = (dictionary == copy)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(dictionary)
  blackHole(copy)
  blackHole(equal)
}

func TreeDictionaryValuesStructElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var dictionary = TreeDictionary<Int64, StructElement>()
  for i in (0..<size) {
    dictionary[Int64(i)] = StructElement(i)
  }
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  blackHole(dictionary)
}

func TreeDictionaryValuesStructElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = TreeDictionary<Int64, StructElement>()
  for i in (0..<size) {
    dictionary[Int64(i)] = StructElement(i)
  }
  benchmark.startMeasurement()
  var copy = dictionary
  copy[Int64(size)] = StructElement(size)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size + 1)
  blackHole(dictionary)
  blackHole(copy)
}

func TreeDictionaryValuesStructElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var dictionary = TreeDictionary<Int64, StructElement>()
  for i in (0..<size) {
    dictionary[Int64(i)] = StructElement(i)
  }
  var copy = TreeDictionary<Int64, StructElement>()
  for (key, value) in dictionary {
    copy[key] = value
  }
  benchmark.startMeasurement()
  let equal = (dictionary == copy)
  benchmark.stopMeasurement()
  precondition(dictionary.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(dictionary)
  blackHole(copy)
  blackHole(equal)
}

func TreeSetCowBoxElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var set = TreeSet<CowBoxElement>()
  for i in (0..<size) {
    set.insert(
      CowBoxElement(i)
    )
  }
  benchmark.stopMeasurement()
  precondition(set.count == size)
  blackHole(set)
}

func TreeSetCowBoxElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var set = TreeSet<CowBoxElement>()
  for i in (0..<size) {
    set.insert(
      CowBoxElement(i)
    )
  }
  benchmark.startMeasurement()
  var copy = set
  copy.insert(
    CowBoxElement(size)
  )
  benchmark.stopMeasurement()
  precondition(set.count == size)
  precondition(copy.count == size + 1)
  blackHole(set)
  blackHole(copy)
}

func TreeSetCowBoxElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var set = TreeSet<CowBoxElement>()
  for i in (0..<size) {
    set.insert(
      CowBoxElement(i)
    )
  }
  var copy = TreeSet<CowBoxElement>()
  for element in set {
    copy.insert(element)
  }
  benchmark.startMeasurement()
  let equal = (set == copy)
  benchmark.stopMeasurement()
  precondition(set.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(set)
  blackHole(copy)
  blackHole(equal)
}

func TreeSetStructElement(
  size: Int,
  benchmark: Benchmark
) {
  benchmark.startMeasurement()
  var set = TreeSet<StructElement>()
  for i in (0..<size) {
    set.insert(
      StructElement(i)
    )
  }
  benchmark.stopMeasurement()
  precondition(set.count == size)
  blackHole(set)
}

func TreeSetStructElementCopy(
  size: Int,
  benchmark: Benchmark
) {
  var set = TreeSet<StructElement>()
  for i in (0..<size) {
    set.insert(
      StructElement(i)
    )
  }
  benchmark.startMeasurement()
  var copy = set
  copy.insert(
    StructElement(size)
  )
  benchmark.stopMeasurement()
  precondition(set.count == size)
  precondition(copy.count == size + 1)
  blackHole(set)
  blackHole(copy)
}

func TreeSetStructElementEqual(
  size: Int,
  benchmark: Benchmark
) {
  var set = TreeSet<StructElement>()
  for i in (0..<size) {
    set.insert(
      StructElement(i)
    )
  }
  var copy = TreeSet<StructElement>()
  for element in set {
    copy.insert(element)
  }
  benchmark.startMeasurement()
  let equal = (set == copy)
  benchmark.stopMeasurement()
  precondition(set.count == size)
  precondition(copy.count == size)
  precondition(equal)
  blackHole(set)
  blackHole(copy)
  blackHole(equal)
}

let benchmarks = {
  
  Benchmark.defaultConfiguration.metrics = .default
  Benchmark.defaultConfiguration.timeUnits = .microseconds
  Benchmark.defaultConfiguration.maxDuration = .seconds(86400)
  Benchmark.defaultConfiguration.maxIterations = .count(100)
  
  let size = 10_000_000
  
  Benchmark("Array<CowBoxElement>") { benchmark in
    ArrayCowBoxElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Array<CowBoxElement> Copy") { benchmark in
    ArrayCowBoxElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Array<CowBoxElement> Equal") { benchmark in
    ArrayCowBoxElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Array<StructElement>") { benchmark in
    ArrayStructElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Array<StructElement> Copy") { benchmark in
    ArrayStructElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Array<StructElement> Equal") { benchmark in
    ArrayStructElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("ContiguousArray<CowBoxElement>") { benchmark in
    ContiguousArrayCowBoxElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("ContiguousArray<CowBoxElement> Copy") { benchmark in
    ContiguousArrayCowBoxElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("ContiguousArray<CowBoxElement> Equal") { benchmark in
    ContiguousArrayCowBoxElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("ContiguousArray<StructElement>") { benchmark in
    ContiguousArrayStructElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("ContiguousArray<StructElement> Copy") { benchmark in
    ContiguousArrayStructElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("ContiguousArray<StructElement> Equal") { benchmark in
    ContiguousArrayStructElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Keys<CowBoxElement>") { benchmark in
    DictionaryKeysCowBoxElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Keys<CowBoxElement> Copy") { benchmark in
    DictionaryKeysCowBoxElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Keys<CowBoxElement> Equal") { benchmark in
    DictionaryKeysCowBoxElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Keys<StructElement>") { benchmark in
    DictionaryKeysStructElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Keys<StructElement> Copy") { benchmark in
    DictionaryKeysStructElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Keys<StructElement> Equal") { benchmark in
    DictionaryKeysStructElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Values<CowBoxElement>") { benchmark in
    DictionaryValuesCowBoxElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Values<CowBoxElement> Copy") { benchmark in
    DictionaryValuesCowBoxElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Values<CowBoxElement> Equal") { benchmark in
    DictionaryValuesCowBoxElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Values<StructElement>") { benchmark in
    DictionaryValuesStructElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Values<StructElement> Copy") { benchmark in
    DictionaryValuesStructElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Dictionary.Values<StructElement> Equal") { benchmark in
    DictionaryValuesStructElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Set<CowBoxElement>") { benchmark in
    SetCowBoxElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Set<CowBoxElement> Copy") { benchmark in
    SetCowBoxElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Set<CowBoxElement> Equal") { benchmark in
    SetCowBoxElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Set<StructElement>") { benchmark in
    SetStructElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Set<StructElement> Copy") { benchmark in
    SetStructElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("Set<StructElement> Equal") { benchmark in
    SetStructElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Keys<CowBoxElement>") { benchmark in
    TreeDictionaryKeysCowBoxElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Keys<CowBoxElement> Copy") { benchmark in
    TreeDictionaryKeysCowBoxElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Keys<CowBoxElement> Equal") { benchmark in
    TreeDictionaryKeysCowBoxElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Keys<StructElement>") { benchmark in
    TreeDictionaryKeysStructElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Keys<StructElement> Copy") { benchmark in
    TreeDictionaryKeysStructElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Keys<StructElement> Equal") { benchmark in
    TreeDictionaryKeysStructElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Values<CowBoxElement>") { benchmark in
    TreeDictionaryValuesCowBoxElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Values<CowBoxElement> Copy") { benchmark in
    TreeDictionaryValuesCowBoxElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Values<CowBoxElement> Equal") { benchmark in
    TreeDictionaryValuesCowBoxElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Values<StructElement>") { benchmark in
    TreeDictionaryValuesStructElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Values<StructElement> Copy") { benchmark in
    TreeDictionaryValuesStructElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeDictionary.Values<StructElement> Equal") { benchmark in
    TreeDictionaryValuesStructElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeSet<CowBoxElement>") { benchmark in
    TreeSetCowBoxElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeSet<CowBoxElement> Copy") { benchmark in
    TreeSetCowBoxElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeSet<CowBoxElement> Equal") { benchmark in
    TreeSetCowBoxElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeSet<StructElement>") { benchmark in
    TreeSetStructElement(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeSet<StructElement> Copy") { benchmark in
    TreeSetStructElementCopy(
      size: size,
      benchmark: benchmark
    )
  }
  
  Benchmark("TreeSet<StructElement> Equal") { benchmark in
    TreeSetStructElementEqual(
      size: size,
      benchmark: benchmark
    )
  }
  
}
