//
//  Functions.swift
//  ReformMath
//
//  Created by Laszlo Korte on 13.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public func rotate(vector: Vec2d, angle: Angle) -> Vec2d {
    let cs = cos(angle.radians)
    let sn = sin(angle.radians)
    
    return Vec2d(x: vector.x * cs - vector.y * sn, y: vector.x * sn + vector.y * cs)
}

public func angle(vector: Vec2d) -> Angle {
    return normalize360(Angle(radians: atan2(vector.y,vector.x)))
}

public func angleBetween(vector a: Vec2d, vector b: Vec2d) -> Angle {
    return normalize360(angle(a) - angle(b))
}

public func clamp<T:Comparable>(value: T, between: T, and: T) -> T {
    return max(between, min(value, and))
}

public func lerp(t:Double, a: Vec2d, b: Vec2d) -> Vec2d {
    return Vec2d(x: lerp(t, a: a.x, b: b.x), y: lerp(t, a: a.y, b: b.y))
}

public func lerp(t:Double, a: Angle, b: Angle) -> Angle {
    return Angle(radians: lerp(t, a: a.radians, b: b.radians))
}

public func lerp(t:Double, a: Double, b: Double) -> Double {
    return a*(1-t) + t*b
}

public func project(vector: Vec2d, onto: Vec2d) -> Vec2d {
    guard onto.x != 0 || onto.y != 0 else { return vector }
    
    return dot(vector, onto) * onto / onto.length2;
}

public func dot(a: Vec2d, _ b: Vec2d) -> Double {
    return a.x * b.x + a.y * b.y
}

public func orthogonal(vector: Vec2d) -> Vec2d {
    return Vec2d(x:-vector.y, y: vector.x)
}

public func signum(num: Double) -> Double {
    if num > 0  { return 1 }
    else if num < 0 { return -1 }
    else { return 0 }
}

public func proportioned(vector: Vec2d, proportion: Double) -> Vec2d {

    let minimum = min(abs(vector.x), abs(vector.y / proportion));
    
    return Vec2d(x: minimum * signum(vector.x), y: minimum * signum(vector.x) * proportion)

}

public func signum(vector: Vec2d) -> Vec2d {
    return Vec2d(x: signum(vector.x), y: signum(vector.y))
}

public func abs(vector: Vec2d) -> Vec2d {
    return Vec2d(x: abs(vector.x), y: abs(vector.y))
}

public func min(vector: Vec2d) -> Double {
    return min(vector.x, vector.y)
}

public func max(vector: Vec2d) -> Double {
    return max(vector.x, vector.y)
}

public func stepped(angle: Angle, size: Angle) -> Angle {
    return Angle(radians: stepped(angle.radians, size: size.radians))
}


public func stepped(value: Double, size: Double) -> Double {
    return round(value / size) * size
}

public func normalize(vector: Vec2d) -> Vec2d? {
    let length = vector.length
    guard length != 0 else {
        return nil
    }
    
    return vector / length
}

public func normalize360(angle: Angle) -> Angle{
    let deg = angle.degree
    let norm = Double(Int(deg) % 360) + (deg-trunc(deg))
    if(norm>0.0) {
        return Angle(degree: norm)
    }
    else {
        return Angle(degree: norm + 360)
    }
}

public func isBetween(angle: Angle, lower: Angle, upper: Angle) -> Bool {
    let a = normalize360(angle)
    let l = normalize360(lower)
    let u = normalize360(upper)
    
    if  l < u {
        return l <= a && a <= u
    } else {
        return l <= a || a <= u
    }
}

public func min(a: Vec2d, _ b: Vec2d) -> Vec2d {
    return Vec2d(x: min(a.x,b.x), y: min(a.y,b.y))
}

public func max(a: Vec2d, _ b: Vec2d) -> Vec2d {
    return Vec2d(x: max(a.x,b.x), y: max(a.y,b.y))
}


public func union(aabb a: AABB2d, aabb b: AABB2d) -> AABB2d {
    return AABB2d(min: min(a.min, b.min), max: max(a.max, b.max))
}