(*****************************************************************************)
(*                                                                           *)
(*                                Dromedary                                  *)
(*                                                                           *)
(*                Alistair O'Brien, University of Cambridge                  *)
(*                                                                           *)
(* Copyright 2021 Alistair O'Brien.                                          *)
(*                                                                           *)
(* All rights reserved. This file is distributed under the terms of the MIT  *)
(* license, as described in the file LICENSE.                                *)
(*                                                                           *)
(*****************************************************************************)

open! Import
open Constraint
module Types = Types
module Typedtree = Typedtree
module Env = Env

let solve ?(debug = false) ~abbrevs cst =
  solve ~debug ~abbrevs cst
  |> Result.map_error ~f:(function
         | `Unify (type_expr1, type_expr2) ->
           [%message
             "Cannot unify types"
               (type_expr1 : Types.type_expr)
               (type_expr2 : Types.type_expr)]
         | `Cycle type_expr ->
           [%message "Cycle occurs" (type_expr : Types.type_expr)]
         | `Unbound_term_variable term_var ->
           [%message
             "Term variable is unbound when solving constraint"
               (term_var : string)]
         | `Unbound_constraint_variable var ->
           [%message
             "Constraint variable is unbound when solving constraint"
               ((var :> int) : int)]
         | `Rigid_variable_escape var ->
           [%message
             "Rigid type variable escaped when generalizing" (var : string)]
         | `Cannot_flexize var ->
           [%message
             "Could not flexize rigid type variable when generalizing"
               (var : string)]
         | `Scope_escape type_expr ->
           [%message
             "Type escape it's equational scope" (type_expr : Types.type_expr)]
         | `Inconsistent_equations ->
           [%message "Inconsistent equations added by local branches"]
         | `Non_rigid_equations -> [%message "Non rigid equations"])


let infer_exp ?(debug = false) ~env:env' ~abbrevs exp =
  let open Result.Let_syntax in
  let%bind exp =
    Infer_core.Expression.(Computation.run ~env:env' (infer_exp_ exp))
  in
  solve ~debug ~abbrevs exp


module Private = struct
  module Constraint = Constraint
  module Computation = Computation
  module Infer_core = Infer_core
  module Algebra = Algebra

  let solve = solve
end