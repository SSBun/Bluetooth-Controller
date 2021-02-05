//
//  ViewConfig.swift
//  babyfs
//
//  Created by caishilin on 2020/3/26.
//  Copyright © 2020 QiMengEducation. All rights reserved.
//

import UIKit

public func config<Object>(_ object: Object, _ config: (Object) throws -> Void) rethrows -> Object {
    try config(object)
    return object
}
