//===- CIROpInterfaces.td - CIR Op Interface Definitions --------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_CIR_OP_INTERFACES
#define MLIR_CIR_OP_INTERFACES

include "mlir/IR/OpBase.td"
include "mlir/IR/SymbolInterfaces.td"
include "mlir/Interfaces/CallInterfaces.td"

let cppNamespace = "::cir" in {
  // The CIRCallOpInterface must be used instead of CallOpInterface when looking
  // at arguments and other bits of CallOp. This creates a level of abstraction
  // that's useful for handling indirect calls and other details.
  def CIRCallOpInterface
      : OpInterface<"CIRCallOpInterface", [CallOpInterface]> {
    let methods = [
      InterfaceMethod<"", "mlir::Operation::operand_iterator",
                      "arg_operand_begin", (ins)>,
      InterfaceMethod<"", "mlir::Operation::operand_iterator",
                      "arg_operand_end", (ins)>,
      InterfaceMethod<
          "Return the operand at index 'i', accounts for indirect call or "
          "exception info",
          "mlir::Value", "getArgOperand",
          (ins "unsigned"
           : $i)>,
      InterfaceMethod<
          "Return the number of operands, accounts for indirect call or "
          "exception info",
          "unsigned", "getNumArgOperands", (ins)>,
      InterfaceMethod<
          "Return the calling convention of the call operation",
          "cir::CallingConv", "getCallingConv", (ins)>,
      InterfaceMethod<
          "Return the side effects of the call operation",
          "cir::SideEffect", "getSideEffect", (ins)>,
    ];
  }

  def CIRGlobalValueInterface
      : OpInterface<"CIRGlobalValueInterface", [Symbol]> {

    let methods = [
      InterfaceMethod<"",
      "bool", "hasAvailableExternallyLinkage", (ins), [{}],
      /*defaultImplementation=*/[{ return false; }]
      >,
      InterfaceMethod<"",
      "bool", "hasLocalLinkage", (ins), [{}],
      /*defaultImplementation=*/[{
        return cir::isLocalLinkage($_op.getLinkage());
      }]
      >,
      InterfaceMethod<"",
      "bool", "hasExternalWeakLinkage", (ins), [{}],
      /*defaultImplementation=*/[{
        return cir::isExternalWeakLinkage($_op.getLinkage());
      }]
      >,
      InterfaceMethod<"",
      "bool", "isExternalLinkage", (ins), [{}],
      /*defaultImplementation=*/[{
        return cir::isExternalLinkage($_op.getLinkage());
      }]
      >,
      InterfaceMethod<"",
      "bool", "isDeclarationForLinker", (ins), [{}],
      /*defaultImplementation=*/[{
        if ($_op.hasAvailableExternallyLinkage())
          return true;
        return $_op.isDeclaration();
      }]
      >,
      InterfaceMethod<"",
      "bool", "hasComdat", (ins), [{}],
      /*defaultImplementation=*/[{
        return $_op.getComdat();
      }]
      >,
      InterfaceMethod<"",
      "void", "setDSOLocal", (ins "bool":$val), [{}],
      /*defaultImplementation=*/[{
        $_op.setDsolocal(val);
      }]
      >,
    ];
    let extraClassDeclaration = [{
    bool hasDefaultVisibility();
    bool canBenefitFromLocalAlias();
  }];
  }

} // namespace cir

#endif // MLIR_CIR_OP_INTERFACES
