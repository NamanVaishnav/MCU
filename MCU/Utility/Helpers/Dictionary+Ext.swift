//
//  Dictionary+Ext.swift
//  MCU
//
//  Created by Naman Vaishnav on 28/06/22.
//

import Foundation

public func + <KeyType, ValueType> (left: [KeyType: ValueType], right: [KeyType: ValueType]) -> [KeyType: ValueType] {
  var out = left

  for (k, v) in right {
    out.updateValue(v, forKey: k)
  }

  return out
}
