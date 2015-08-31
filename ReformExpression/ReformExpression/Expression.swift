//
//  Expression.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public enum EvaluationError : ErrorType {
    case UnresolvedReference(message: String)
    case ArithmeticError(message: String)
    case TypeMismatch(message: String)
    case ParameterCountMismatch(message: String)
    case DuplicateDefinition(referenceId: ReferenceId)
}

public protocol UnaryOperator {
    init()
    func apply(value: Value) -> Result<Value, EvaluationError>
}

public protocol BinaryOperator {
    init()
    func apply(lhs: Value, rhs: Value) -> Result<Value, EvaluationError>
}

public enum FunctionArity {
    case Fix(Int)
    case Variadic
    
    func accept(count: Int) -> Bool {
        switch self {
        case Fix(count):
            return true
        case .Variadic:
            return true
        default:
            return false
        }
    }
}

public protocol Function {
    static var arity : FunctionArity { get }
    init()
    func apply(params: [Value]) -> Result<Value, EvaluationError>
}

public func ==(left: ReferenceId, right: ReferenceId) -> Bool {
    return left.value == right.value
}

public enum Expression : Equatable {
    case Constant(Value)
    case NamedConstant(String, Value)
    case Reference(id: ReferenceId)
    indirect case Unary(UnaryOperator, Expression)
    indirect case Binary(BinaryOperator, Expression, Expression)
    indirect case Call(Function, [Expression])
}

public func ==(lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
    case (.Constant(let l), .Constant(let r)):
        return l == r
    case (.NamedConstant(let l), .NamedConstant(let r)):
        return l.0 == r.0 && l.1 == r.1
    case (.Reference(let l), .Reference(let r)):
        return l == r
    case (.Unary(let opl,let l), .Unary(let opr, let r)):
        return opl.dynamicType == opr.dynamicType && l == r
    case (.Binary(let opl,let l1, let l2), .Binary(let opr, let r1, let r2)):
        return opl.dynamicType == opr.dynamicType && l1 == r1 && l2 == r2
    case (.Call(let fl, let argl), .Call(let fr, let argr)):
        return fl.dynamicType == fr.dynamicType && argl == argr
        
    default:
        return false
    }
}

extension Expression {
    public func eval(dataSet: DataSet) -> Result<Value, EvaluationError> {
        switch(self) {
        case .Constant(let value):
            return .Success(value)
        case .NamedConstant(_, let value):
            return .Success(value)
        case .Reference(let id):
            if let value = dataSet.lookUp(id) {
                return .Success(value)
            } else {
                return .Fail(.UnresolvedReference(message: "[?\(id.value)]"))
            }
        case .Unary(let op, let expr):
            switch expr.eval(dataSet) {
            case .Success(let val):
                return op.apply(val)
            case .Fail(let error):
                return .Fail(error)
            }
        case .Binary(let op, let lhs, let rhs):
            
            switch lhs.eval(dataSet) {
            case .Success(let leftValue):
                switch rhs.eval(dataSet) {
                case .Success(let rightValue):
                    return op.apply(leftValue, rhs: rightValue)
                case .Fail(let rightError):
                    return .Fail(rightError)
                }
            case .Fail(let leftError):
                return .Fail(leftError)
            }
        case .Call(let function, let params):
            guard function.dynamicType.arity.accept(params.count) else {
                return .Fail(.ParameterCountMismatch(message: "Amount of parameters does not match"))
            }
            
            var paramValues = [Value]()
            for p in params {
                switch p.eval(dataSet) {
                case .Success(let value):
                    paramValues.append(value)
                case .Fail(let error):
                    return .Fail(error)
                }
            }
            
            return function.apply(paramValues)
        }
    }
}