(* Yoann Padioleau
 *
 * Copyright (C) 2010, 2011 Facebook
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)

open Common

open Ocaml (* for v_int, v_bool, etc *)

open Ast_php

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(*****************************************************************************)
(* Side effect style visitor *)
(*****************************************************************************)

(*
 * Visitors for all language concepts, not just for expression.
 *
 * Note that I don't visit necesserally in the order of the tokens
 * found in the original file. So don't assume such hypothesis!
 *
 * Mostly generated by ocamltarzan with: camlp4o -o /tmp/yyy.ml -I pa/ pa_type_conv.cmo pa_visitor.cmo  pr_o.cmo /tmp/xxx.ml
 * and then manually adjusted.
 *
 * update: used to have multiple v_parenxxx and v_wrap because of the "value
 *  restriction" of ocaml but 3.12 fixed that :)
 * update: reordered a few things to help unparse_php.ml
 * update: instead of generating a set of vxxx I now just generate
 *  a vout = vany. This helps avoid the proliferation of functions
 *  like ii_of_expr, ii_of_stmt, etc. You just need a ii_of_any now.
 *  Is is the final design ? Could we factorize vin ?
 *)

module Scope_php = struct
(* TODO ? need visitor for scope ? *)
let v_phpscope _x = ()
end

(* todo? why don't use the one in Ocaml.ml ? because it generates
 * a compilation error :(
 *)
let v_ref _aref _x = () (* dont go into ref *)

(* hooks *)
type visitor_in = {
  kexpr: (expr  -> unit) * visitor_out -> expr  -> unit;
  kstmt: (stmt  -> unit) * visitor_out -> stmt  -> unit;
  ktop: (toplevel -> unit) * visitor_out -> toplevel  -> unit;
  kconstant: (constant -> unit) * visitor_out -> constant  -> unit;
  kscalar: (scalar -> unit) * visitor_out -> scalar  -> unit;
  kencaps: (encaps -> unit) * visitor_out -> encaps -> unit;
  kclass_stmt: (class_stmt -> unit) * visitor_out -> class_stmt -> unit;
  kparameter: (parameter -> unit) * visitor_out -> parameter -> unit;
  kargument: (argument -> unit) * visitor_out -> argument -> unit;
  kcatch: (catch -> unit) * visitor_out -> catch -> unit;
  kfinally: (finally -> unit) * visitor_out -> finally -> unit;

  kxhp_html:
    (xhp_html -> unit) * visitor_out -> xhp_html -> unit;
  kxhp_tag:
    (xhp_tag wrap -> unit) * visitor_out -> xhp_tag wrap -> unit;
  kxhp_attribute:
    (xhp_attribute -> unit) * visitor_out -> xhp_attribute -> unit;
  kxhp_attr_decl:
    (xhp_attribute_decl -> unit) * visitor_out -> xhp_attribute_decl -> unit;
  kxhp_children_decl:
    (xhp_children_decl -> unit) * visitor_out -> xhp_children_decl -> unit;

  kfunc_def:
    (func_def -> unit) * visitor_out -> func_def -> unit;
  kclass_def:
    (class_def -> unit) * visitor_out -> class_def -> unit;
  kmethod_def:
    (method_def -> unit) * visitor_out -> method_def -> unit;

  kstmt_and_def_list_scope:
    (stmt_and_def list -> unit) * visitor_out -> stmt_and_def list  -> unit;

  kname: (name -> unit) * visitor_out -> name -> unit;
  khint_type: (hint_type -> unit) * visitor_out -> hint_type -> unit;
  ktparam: (type_param -> unit) * visitor_out -> type_param -> unit;
  karray_pair: (array_pair -> unit) * visitor_out -> array_pair -> unit;

  karguments: (argument comma_list paren -> unit) * visitor_out ->
    argument comma_list paren -> unit;

  kcomma: (tok -> unit) * visitor_out -> tok -> unit;
  kinfo: (tok -> unit)  * visitor_out -> tok  -> unit;
}
and visitor_out = any -> unit

let default_visitor =
  { kexpr   = (fun (k,_) x -> k x);
    kstmt   = (fun (k,_) x -> k x);
    ktop    = (fun (k,_) x -> k x);
    kconstant    = (fun (k,_) x -> k x);
    kscalar    = (fun (k,_) x -> k x);
    kencaps = (fun (k,_) x -> k x);
    kinfo   = (fun (k,_) x -> k x);
    kclass_stmt = (fun (k,_) x -> k x);
    kparameter = (fun (k,_) x -> k x);
    kargument = (fun (k,_) x -> k x);
    karguments = (fun (k,_) x -> k x);
    kcatch = (fun (k,_) x -> k x);
    kfinally = (fun (k,_) x -> k x);

    kstmt_and_def_list_scope    = (fun (k,_) x -> k x);

    kfunc_def = (fun (k,_) x -> k x);
    kmethod_def = (fun (k,_) x -> k x);
    kclass_def = (fun (k,_) x -> k x);

    kcomma   = (fun (k,_) x -> k x);

    khint_type  = (fun (k,_) x -> k x);
    kname  = (fun (k,_) x -> k x);

    kxhp_html = (fun (k,_) x -> k x);
    kxhp_tag = (fun (k,_) x -> k x);
    kxhp_attribute = (fun (k,_) x -> k x);

    kxhp_attr_decl = (fun (k,_) x -> k x);
    kxhp_children_decl = (fun (k,_) x -> k x);
    karray_pair =  (fun (k,_) x -> k x);
    ktparam = (fun (k,_) x -> k x);
  }


let (mk_visitor: visitor_in -> visitor_out) = fun vin ->

(* start of auto generation *)

let rec v_info x  =
  let k x = match x with { Parse_info.token = _v_pinfo; _ } ->
  (* TODO ? not sure what behavior we want with tokens and fake tokens.
  *)
    (*let arg = v_parse_info v_pinfo in *)
    ()
  in
  vin.kinfo (k, all_functions) x

(* since ocaml 3.12 we can now use polymorphic recursion instead of having
 * to duplicate the same function again and again.
 *)
and v_wrap: 'a. ('a -> unit) -> 'a wrap -> unit = fun _of_a (v1, v2) ->
  let v1 = _of_a v1 and v2 = v_info v2 in ()
and v_tok v = v_info v
and v_paren: 'a. ('a -> unit) -> 'a paren -> unit = fun _of_a (v1, v2, v3) ->
  let v1 = v_tok v1 and v2 = _of_a v2 and v3 = v_tok v3 in ()
and v_brace: 'a. ('a -> unit) -> 'a brace -> unit = fun _of_a (v1, v2, v3) ->
  let v1 = v_tok v1 and v2 = _of_a v2 and v3 = v_tok v3 in ()
and v_bracket: 'a. ('a -> unit) -> 'a bracket -> unit = fun _of_a (v1, v2, v3)->
  let v1 = v_tok v1 and v2 = _of_a v2 and v3 = v_tok v3 in ()
and v_single_angle: 'a. ('a -> unit) -> 'a single_angle -> unit = fun _of_a (v1, v2, v3)->
  let v1 = v_tok v1 in
  let v2 = _of_a v2 in
  let v3 = v_tok v3 in ()
and v_angle: 'a. ('a -> unit) -> 'a angle -> unit = fun _of_a (v1, v2, v3)->
  let v1 = v_tok v1 and v2 = _of_a v2 and v3 = v_tok v3 in ()
and v_comma x =
  let k info = v_tok info
  in
  vin.kcomma (k, all_functions) x
and v_comma_list_dots : 'a. ('a -> unit) -> 'a comma_list_dots -> unit = fun _of_a xs ->
  xs +> List.iter (function
  | Left3 x -> _of_a x
  | Middle3 info -> v_tok info
  | Right3 info -> v_comma info
  )
and v_comma_list: 'a. ('a -> unit) -> 'a comma_list -> unit = fun _of_a xs ->
  xs +> List.iter (function | Left x -> _of_a x | Right info -> v_comma info)

and v_ptype =
  function
  | BoolTy -> ()
  | IntTy -> ()
  | DoubleTy -> ()
  | StringTy -> ()
  | ArrayTy -> ()
  | ObjectTy -> ()



and v_ident = function
  | Name v1 -> let v1 = v_wrap v_string v1 in ()
  | XhpName v1 -> let v1 = v_xhp_tag_wrap v1 in ()

and v_qualified_ident v = v_list v_qualified_ident_element v
and v_qualified_ident_element =
  function
  | QI v1 -> let v1 = v_ident v1 in ()
  | QITok v1 -> let v1 = v_tok v1 in ()


and v_dname = function | DName v1 -> let v1 = v_wrap v_string v1 in ()
and v_xhp_tag v = v_list v_string v
and v_xhp_tag_wrap x =
  let k v = v_wrap v_xhp_tag v in
  vin.kxhp_tag (k, all_functions) x

and v_name x = v_class_name_or_selfparent x
and v_class_name_or_selfparent x =
  let k x =
    match x with
  | XName (v1) ->
      let v1 = v_qualified_ident v1 in
      ()
  | Self v1 -> let v1 = v_tok v1 in ()
  | Parent v1 -> let v1 = v_tok v1 in ()
  | LateStatic v1 -> let v1 = v_tok v1 in ()
  in
  vin.kname (k, all_functions) x
and v_type_args x =
  v_single_angle (v_comma_list v_hint_type) x; ()
and v_type_params v = v_single_angle (v_comma_list v_type_param) v
and v_type_param x =
  let k x =
    match x with
  | TParam v1 -> let v1 = v_ident v1 in ()
  | TParamConstraint ((v1, v2, v3)) ->
      let v1 = v_ident v1 and v2 = v_tok v2 and v3 = v_class_name v3 in ()
  in
  vin.ktparam (k, all_functions) x
and v_class_name v = v_hint_type v

and v_fully_qualified_class_name v = v_hint_type v

and v_expr (x: expr) =
  (* tweak *)
  let k x =  match x with
  | Id v1 ->
    v_name v1

  | IdVar ((v1, v2)) ->
      let v1 = v_dname v1 and v2 = v_ref Scope_php.v_phpscope v2 in ()
  | This v1 -> let v1 = v_tok v1 in ()


  | Call ((v1, v2)) ->
      let v1 = v_expr v1 and v2 = v_paren (v_comma_list v_argument) v2 in ()
  | ObjGet ((v1, v2, v3)) ->
      let v1 = v_expr v1 and v2 = v_tok v2 and v3 = v_expr v3 in ()
  | ClassGet ((v1, v2, v3)) ->
      let v1 = v_class_name_reference v1
      and v2 = v_tok v2
      and v3 = v_expr v3
      in ()
  | ArrayGet ((v1, v2)) ->
      let v1 = v_expr v1 and v2 = v_bracket (v_option v_expr) v2 in ()
  | HashGet ((v1, v2)) -> let v1 = v_expr v1 and v2 = v_brace v_expr v2 in ()
  | BraceIdent v1 -> let v1 = v_brace v_expr v1 in ()
  | Deref ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | Sc v1 -> let v1 = v_scalar v1 in ()
  | Assign ((v1, v2, v3)) ->
      let v1 = v_lvalue v1 and v2 = v_tok v2 and v3 = v_expr v3 in ()
  | AssignRef ((v1, v2, v3, v4)) ->
      let v1 = v_lvalue v1
      and v2 = v_tok v2
      and v3 = v_tok v3
      and v4 = v_lvalue v4
      in ()
  | AssignNew ((v1, v2, v3, v4, v5, v6)) ->
      let v1 = v_lvalue v1
      and v2 = v_tok v2
      and v3 = v_tok v3
      and v4 = v_tok v4
      and v5 = v_class_name_reference v5
      and v6 = v_option (v_arguments) v6
      in ()
  | AssignOp ((v1, v2, v3)) ->
      let v1 = v_lvalue v1
      and v2 = v_wrap v_assignOp v2
      and v3 = v_expr v3
      in ()
  | Postfix ((v1, v2)) ->
      let v1 = v_rw_variable v1 and v2 = v_wrap v_fixOp v2 in ()
  | Infix ((v1, v2)) ->
      let v1 = v_wrap v_fixOp v1 and v2 = v_rw_variable v2 in ()
  | Binary ((v1, v2, v3)) ->
      let v1 = v_expr v1
      and v2 = v_wrap v_binaryOp v2
      and v3 = v_expr v3
      in ()
  | Unary ((v1, v2)) -> let v1 = v_wrap v_unaryOp v1 and v2 = v_expr v2 in ()
  | CondExpr ((v1, v2, v3, v4, v5)) ->
      let v1 = v_expr v1
      and v2 = v_tok v2
      and v3 = v_option v_expr v3
      and v4 = v_tok v4
      and v5 = v_expr v5
      in ()
  | AssignList ((v1, v2, v3, v4)) ->
      let v1 = v_tok v1
      and v2 = v_paren (v_comma_list v_list_assign) v2
      and v3 = v_tok v3
      and v4 = v_expr v4
      in ()
  | ArrayLong ((v1, v2)) ->
      let v1 = v_tok v1 and v2 = v_paren (v_comma_list v_array_pair) v2 in ()
  | ArrayShort ((v1)) ->
      let v1 = v_bracket (v_comma_list v_array_pair) v1 in ()
  | Collection ((v1, v2)) ->
      let v1 = v_name v1 in
      let v2 = v_brace (v_comma_list v_array_pair) v2 in ()
  | New ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_class_name_reference v2
      and v3 = v_option (v_arguments) v3
      in ()
  | Clone ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | InstanceOf ((v1, v2, v3)) ->
      let v1 = v_expr v1
      and v2 = v_tok v2
      and v3 = v_class_name_reference v3
      in ()
  | Cast ((v1, v2)) -> let v1 = v_wrap v_castOp v1 and v2 = v_expr v2 in ()
  | CastUnset ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | Exit ((v1, v2)) ->
      let v1 = v_tok v1
      and v2 = v_option (v_paren (v_option v_expr)) v2
      in ()
  | At ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | Print ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | Lambda v1 -> let v1 = v_lambda_def v1 in ()
  | ShortLambda v1 -> let v1 = v_short_lambda_def v1 in ()
  | BackQuote ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_list v_encaps v2 and v3 = v_tok v3 in ()
  | Include ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | IncludeOnce ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | Require ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | RequireOnce ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | Yield ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | YieldBreak ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_tok v2 in ()
  | Await ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_expr v2 in ()
  | Empty ((v1, v2)) ->
      let v1 = v_tok v1 and v2 = v_paren v_lvalue v2 in ()
  | Isset ((v1, v2)) ->
      let v1 = v_tok v1 and v2 = v_paren (v_comma_list v_lvalue) v2 in ()
  | Eval ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_paren v_expr v2 in ()
  | ParenExpr v1 -> let v1 = v_paren v_expr v1 in ()

  | SgrepExprDots v1 -> let v1 = v_tok v1 in ()

  | XhpHtml v1 -> let v1 = v_xhp_html v1 in ()

  in
  vin.kexpr (k, all_functions) x
and v_lambda_def (v1, v2) =
  let v1 = v_option v_lexical_vars v1 and v2 = v_func_def v2 in ()
and
  v_short_lambda_def {
                       sl_params = v_sl_params;
                       sl_tok = v_sl_tok;
                       sl_body = v_sl_body
                     } =
  let arg = v_short_lambda_params v_sl_params in
  let arg = v_tok v_sl_tok in let arg = v_short_lambda_body v_sl_body in ()
and v_short_lambda_params =
  function
  | SLSingleParam v1 -> let v1 = v_parameter v1 in ()
  | SLParams v1 -> let v1 = v_paren (v_comma_list_dots v_parameter) v1 in ()
and v_short_lambda_body =
  function
  | SLExpr v1 -> let v1 = v_expr v1 in ()
  | SLBody v1 -> let v1 = v_brace (v_list v_stmt_and_def) v1 in ()
and v_stmt_and_def x = v_stmt x
and v_parameters x =
    v_paren (v_comma_list_dots v_parameter) x

and v_lexical_vars (v1, v2) =
  let v1 = v_tok v1
  and v2 = v_paren (v_comma_list v_lexical_var) v2
  in ()
and v_lexical_var =
  function
  | LexicalVar ((v1, v2)) -> let v1 = v_is_ref v1 and v2 = v_dname v2 in ()

and v_scalar v =
  let k x =
    match x with
  | C v1 -> let v1 = v_constant v1 in ()
  | Guil ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_list v_encaps v2 and v3 = v_tok v3 in ()
  | HereDoc ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_list v_encaps v2 and v3 = v_tok v3 in ()
  in
  vin.kscalar (k, all_functions) v

and v_static_scalar x = v_expr x

and v_static_scalar_affect (v1, v2) =
  let v1 = v_tok v1 and v2 = v_static_scalar v2 in ()
and v_constant x =
  let k x =  match x with
  | Ast_php.Int v1 -> let v1 = v_wrap v_string v1 in ()
  | Double v1 -> let v1 = v_wrap v_string v1 in ()
  | String v1 -> let v1 = v_wrap v_string v1 in ()
  | PreProcess v1 -> let v1 = v_wrap v_cpp_directive v1 in ()
  | XdebugClass ((v1, v2)) ->
      let v1 = v_name v1 and v2 = v_list v_class_stmt v2 in ()
  | XdebugResource -> ()
  in
  vin.kconstant (k, all_functions) x


and v_cpp_directive =
  function
  | Line -> ()
  | File -> ()
  | Dir -> ()
  | ClassC -> ()
  | MethodC -> ()
  | FunctionC -> ()
  | TraitC -> ()
  | NamespaceC -> ()

and v_encaps x =
  let k x = match x with
  | EncapsString v1 -> let v1 = v_wrap v_string v1 in ()
  | EncapsVar v1 -> let v1 = v_lvalue v1 in ()
  | EncapsCurly ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_lvalue v2 and v3 = v_tok v3 in ()
  | EncapsDollarCurly ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_lvalue v2 and v3 = v_tok v3 in ()
  | EncapsExpr ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_expr v2 and v3 = v_tok v3 in ()
  in
  vin.kencaps (k, all_functions) x

and v_fixOp = function | Dec -> () | Inc -> ()
and v_binaryOp =
  function
  | Arith v1 -> let v1 = v_arithOp v1 in ()
  | Logical v1 -> let v1 = v_logicalOp v1 in ()
  | BinaryConcat -> ()
and v_arithOp =
  function
  | Plus -> ()
  | Minus -> ()
  | Mul -> ()
  | Div -> ()
  | Mod -> ()
  | DecLeft -> ()
  | DecRight -> ()
  | And -> ()
  | Or -> ()
  | Xor -> ()
and v_logicalOp =
  function
  | Inf -> ()
  | Sup -> ()
  | InfEq -> ()
  | SupEq -> ()
  | Eq -> ()
  | NotEq -> ()
  | Identical -> ()
  | NotIdentical -> ()
  | AndLog -> ()
  | OrLog -> ()
  | XorLog -> ()
  | AndBool -> ()
  | OrBool -> ()
and v_assignOp =
  function
  | AssignOpArith v1 -> let v1 = v_arithOp v1 in ()
  | AssignConcat -> ()
and v_unaryOp =
  function | UnPlus -> () | UnMinus -> () | UnBang -> () | UnTilde -> ()
and v_castOp v = v_ptype v
and v_class_name_reference x = v_expr x

and v_list_assign =
  function
  | ListVar v1 -> let v1 = v_lvalue v1 in ()
  | ListList ((v1, v2)) ->
      let v1 = v_tok v1 and v2 = v_paren (v_comma_list v_list_assign) v2 in ()
  | ListEmpty -> ()
and v_array_pair x =
  let k x = match x with
  | ArrayExpr v1 -> let v1 = v_expr v1 in ()
  | ArrayRef ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_lvalue v2 in ()
  | ArrayArrowExpr ((v1, v2, v3)) ->
      let v1 = v_expr v1 and v2 = v_tok v2 and v3 = v_expr v3 in ()
  | ArrayArrowRef ((v1, v2, v3, v4)) ->
      let v1 = v_expr v1
      and v2 = v_tok v2
      and v3 = v_tok v3
      and v4 = v_lvalue v4
      in ()
  in
  vin.karray_pair (k, all_functions) x
and v_xhp_html x =
  let k x =
    match x with
    | Xhp ((v1, v2, v3, v4, v5)) ->
      let v1 = v_xhp_tag_wrap v1
      and v2 = v_list v_xhp_attribute v2
      and v3 = v_tok v3
      and v4 = v_list v_xhp_body v4
      and v5 = v_wrap (v_option v_xhp_tag) v5
      in ()
   | XhpSingleton ((v1, v2, v3)) ->
      let v1 = v_xhp_tag_wrap v1
      and v2 = v_list v_xhp_attribute v2
      and v3 = v_tok v3
      in ()
  in
  vin.kxhp_html (k, all_functions) x

and v_xhp_attribute x =
  let k (v1, v2, v3) =
  let v1 = v_xhp_attr_name v1
  and v2 = v_tok v2
  and v3 = v_xhp_attr_value v3
  in ()
  in
  vin.kxhp_attribute (k, all_functions) x

and v_xhp_attr_name v = v_wrap v_string v
and v_xhp_attr_value =
  function
  | XhpAttrString ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_list v_encaps v2 and v3 = v_tok v3 in ()
  | XhpAttrExpr v1 -> let v1 = v_brace v_expr v1 in ()
  | SgrepXhpAttrValueMvar v1 ->
      let v1 = v_wrap v_string v1 in ()
and v_xhp_body =
  function
  | XhpText v1 -> let v1 = v_wrap v_string v1 in ()
  | XhpExpr v1 -> let v1 = v_brace v_expr v1 in ()
  | XhpNested v1 -> let v1 = v_xhp_html v1 in ()

and v_lvalue x = v_expr x

and v_arguments x =
  let k x =
    v_paren (v_comma_list v_argument) x
  in
  vin.karguments (k, all_functions) x

and v_argument x =
  let k = function
  | Arg v1 -> let v1 = v_expr v1 in ()
  | ArgRef ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_w_variable v2 in ()
  in
  vin.kargument (k, all_functions) x

and v_rw_variable v = v_lvalue v
and v_r_variable v = v_lvalue v
and v_w_variable v = v_lvalue v


and v_stmt xxx =
  (* tweak *)
  let k xxx = match xxx with

  | ExprStmt ((v1, v2)) -> let v1 = v_expr v1 and v2 = v_tok v2 in ()
  | EmptyStmt v1 -> let v1 = v_tok v1 in ()
  | Block v1 -> let v1 = v_brace (v_stmt_and_def_list_scope) v1 in ()
  | If ((v1, v2, v3, v4, v5)) ->
      let v1 = v_tok v1
      and v2 = v_paren v_expr v2
      and v3 = v_stmt v3
      and v4 = v_list v_elseif v4
      and v5 = v_option v_xelse v5
      in ()
  | IfColon ((v1, v2, v3, v4, v5, v6, v7, v8)) ->
      let v1 = v_tok v1
      and v2 = v_paren v_expr v2
      and v3 = v_tok v3
      and v4 = v_stmt_and_def_list_scope v4
      and v5 = v_list v_new_elseif v5
      and v6 = v_option v_new_else v6
      and v7 = v_tok v7
      and v8 = v_tok v8
      in ()
  | While ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_paren v_expr v2
      and v3 = v_colon_stmt v3
      in ()
  | Do ((v1, v2, v3, v4, v5)) ->
      let v1 = v_tok v1
      and v2 = v_stmt v2
      and v3 = v_tok v3
      and v4 = v_paren v_expr v4
      and v5 = v_tok v5
      in ()
  | For ((v1, v2, v3, v4, v5, v6, v7, v8, v9)) ->
      let v1 = v_tok v1
      and v2 = v_tok v2
      and v3 = v_for_expr v3
      and v4 = v_tok v4
      and v5 = v_for_expr v5
      and v6 = v_tok v6
      and v7 = v_for_expr v7
      and v8 = v_tok v8
      and v9 = v_colon_stmt v9
      in ()
  | Switch ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_paren v_expr v2
      and v3 = v_switch_case_list v3
      in ()
  | Foreach ((v1, v2, v3, v4, v5, v6, v7, v8)) ->
      let v1 = v_tok v1
      and v2 = v_tok v2
      and v3 = v_expr v3
      and v4 = v_option v_tok v4
      and v5 = v_tok v5
      and v6 = v_foreach_pattern v6
      and v7 = v_tok v7
      and v8 = v_colon_stmt v8
      in ()
  | Break ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_option v_expr v2 and v3 = v_tok v3 in ()
  | Continue ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_option v_expr v2 and v3 = v_tok v3 in ()
  | Return ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_option v_expr v2 and v3 = v_tok v3 in ()
  | Throw ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_expr v2 and v3 = v_tok v3 in ()
  | Try ((v1, v2, v3, v4)) ->
      let v1 = v_tok v1
      and v2 = v_brace (v_stmt_and_def_list_scope) v2
      and v3 = v_list v_catch v3
      and v4 = v_list v_finally v4
      in ()
  | Echo ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_comma_list v_expr v2 and v3 = v_tok v3 in ()
  | InlineHtml (v1) ->
      let v1 = v_wrap v_string v1 in ()

  | Globals ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_comma_list v_global_var v2
      and v3 = v_tok v3
      in ()
  | StaticVars ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_comma_list v_static_var v2
      and v3 = v_tok v3
      in ()
  | Use ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_use_filename v2 and v3 = v_tok v3 in ()
  | Unset ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_paren (v_comma_list v_lvalue) v2
      and v3 = v_tok v3
      in ()
  | Declare ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_paren (v_comma_list v_declare) v2
      and v3 = v_colon_stmt v3
      in
      ()
  | FuncDefNested v1 -> let v1 = v_func_def v1 in ()
  | ClassDefNested v1 -> let v1 = v_class_def v1 in ()
  in
  vin.kstmt (k,all_functions) xxx




and v_colon_stmt =
  function
  | SingleStmt v1 -> let v1 = v_stmt v1 in ()
  | ColonStmt ((v1, v2, v3, v4)) ->
      let v1 = v_tok v1
      and v2 = v_stmt_and_def_list_scope v2
      and v3 = v_tok v3
      and v4 = v_tok v4
      in ()
and v_elseif (v1, v2, v3) =
  let v1 = v_tok v1 and v2 = v_paren v_expr v2 and v3 = v_stmt v3 in ()
and v_xelse (v1, v2) = let v1 = v_tok v1 and v2 = v_stmt v2 in ()
and v_new_elseif (v1, v2, v3, v4) =
  let v1 = v_tok v1
  and v2 = v_paren v_expr v2
  and v3 = v_tok v3
  and v4 = v_stmt_and_def_list_scope v4
  in ()
and v_new_else (v1, v2, v3) =
  let v1 = v_tok v1 and v2 = v_tok v2 and v3 = v_stmt_and_def_list_scope v3 in ()
and v_for_expr v = v_comma_list v_expr v
and v_foreach_pattern =
  function
  | ForeachVar v1 -> let v1 = v_foreach_variable v1 in ()
  | ForeachArrow ((v1, v2, v3)) ->
      let v1 = v_foreach_pattern v1
      and v2 = v_tok v2
      and v3 = v_foreach_pattern v3
      in ()
  | ForeachList ((v1, v2)) ->
      let v1 = v_tok v1
      and v2 = v_paren (v_comma_list v_list_assign) v2
      in ()
and v_foreach_variable (v1, v2) =
  let v1 = v_is_ref v1 and v2 = v_lvalue v2 in ()
and v_switch_case_list =
  function
  | CaseList ((v1, v2, v3, v4)) ->
      let v1 = v_tok v1
      and v2 = v_option v_tok v2
      and v3 = v_list v_case v3
      and v4 = v_tok v4
      in ()
  | CaseColonList ((v1, v2, v3, v4, v5)) ->
      let v1 = v_tok v1
      and v2 = v_option v_tok v2
      and v3 = v_list v_case v3
      and v4 = v_tok v4
      and v5 = v_tok v5
      in ()
and v_case =
  function
  | Case ((v1, v2, v3, v4)) ->
      let v1 = v_tok v1
      and v2 = v_expr v2
      and v3 = v_tok v3
      and v4 = v_stmt_and_def_list_scope v4
      in ()
  | Default ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_tok v2 and v3 = v_stmt_and_def_list_scope v3 in ()
and v_catch x =
  let k x =
    let (v1, v2, v3) = x in

    let v1 = v_tok v1
    and v2 =
      v_paren
        (fun (v1, v2) ->
          let v1 = v_fully_qualified_class_name v1 and v2 = v_dname v2 in ())
        v2
    and v3 = v_brace (v_stmt_and_def_list_scope) v3
    in ()
  in
  vin.kcatch (k, all_functions) x
and v_finally x =
  let k x =
    let (v1, v2) = x in

    let v1 = v_tok v1
    and v2 = v_brace (v_stmt_and_def_list_scope) v2
    in ()
  in
  vin.kfinally (k, all_functions) x

and v_use_filename =
  function
  | UseDirect v1 -> let v1 = v_wrap v_string v1 in ()
  | UseParen v1 -> let v1 = v_paren (v_wrap v_string) v1 in ()
and v_declare (v1, v2) =
  let v1 = v_ident v1 and v2 = v_static_scalar_affect v2 in ()
and
  v_func_def x =
  let k x =
    match x with {
               f_tok = v_f_tok;
               f_type = v_f_type;
               f_attrs = v_f_attrs;
               f_modifiers = v_f_modifiers;
               f_ref = v_f_ref;
               f_tparams = v_f_tparams;
               f_name = v_f_name;
               f_params = v_f_params;
               f_body = v_f_body;
               f_return_type = v_f_return_type;
             } ->
  let arg = v_tok v_f_tok in
  let arg = v_option v_attributes v_f_attrs in
  let arg = v_function_type v_f_type in
  let arg = v_list (v_wrap v_modifier) v_f_modifiers in
  let arg = v_is_ref v_f_ref in
  let arg = v_ident v_f_name in
  let arg = v_option v_type_params v_f_tparams in
  let arg = v_parameters v_f_params in
  let arg = v_body v_f_body in
  let arg =
    v_option
      (fun (v1, v2, v3) -> 
        let v1 = v_tok v1 
        and v2  = v_option v_tok v2
        and v3 = v_hint_type v3 in ())
      v_f_return_type in
  ()
  in
  vin.kfunc_def (k, all_functions) x
and v_function_type =
  function
  | FunctionRegular -> ()
  | FunctionLambda -> ()
  | MethodRegular -> ()
  | MethodAbstract -> ()

and v_parameter x =
  let k x =
    match x with
    {
      p_attrs = v_p_attrs;
      p_modifier = v_p_modifier;
      p_soft_type = v_p_soft_type;
      p_type = v_p_type;
      p_ref = v_p_ref;
      p_name = v_p_name;
      p_default = v_p_default
    } ->
      let arg = v_option v_attributes v_p_attrs in
      let arg = v_option (v_wrap v_modifier) v_p_modifier in
      let arg = v_option v_hint_type v_p_type in
      let arg = v_option v_tok v_p_soft_type in
      let arg = v_is_ref v_p_ref in
      let arg = v_dname v_p_name in
      let arg = v_option v_static_scalar_affect v_p_default
      in ()
  in
  vin.kparameter (k, all_functions) x
and v_hint_type x =
  let k x = match x with
  | Hint (v1, v2) -> 
    let v1 = v_class_name_or_selfparent v1 in
    let v2 = v_option v_type_args v2 in
    ()
  | HintArray v1 -> let v1 = v_tok v1 in ()
  | HintQuestion (v1, v2) -> let v1 = v_tok v1 in
                             let v2 = v_hint_type v2 in ()
  | HintTuple v1 -> let v1 = v_paren (v_comma_list v_hint_type) v1 in ()

  | HintCallback v1 ->
      let v1 =
        v_paren
          (fun (v1, v2, v3) ->
             let v1 = v_tok v1
             and v2 = v_paren (v_comma_list_dots v_hint_type) v2
             and v3 =
               v_option
                 (fun (v1, v2, v3) ->
                    let v1 = v_tok v1 
                    and v2 = v_option v_tok v2
                    and v3 = v_hint_type v3 in ())
                 v3
             in ())
          v1
      in ()
  | HintShape ((v1, v2)) ->
      let v1 = v_tok v1
      and v2 =
        v_paren
          (v_comma_list
             (fun (v1, v2, v3) ->
                let v1 = v_expr v1
                and v2 = v_tok v2
                and v3 = v_hint_type v3
                in ()))
          v2
      in ()
  in
  vin.khint_type (k, all_functions) x

and v_is_ref v = v_option v_tok v

and v_constraint (v1, v2) =
  let v1 = v_tok v1 in
  let v2 = v_hint_type v2 in
  ()
and v_enum_type {
                  e_tok = v_e_tok;
                  e_base = v_e_base;
                  e_constraint = v_e_constraint;
                 } =
  let v1 = v_tok v_e_tok in
  let v2 = v_hint_type v_e_base in
  let v3 = v_option v_constraint v_e_constraint in
  ()

and
  v_class_def x =
  let k {
                c_type = v_c_type;
                c_name = v_c_name;
                c_tparams = v_c_tparams;
                c_extends = v_c_extends;
                c_implements = v_c_implements;
                c_body = v_c_body;
                c_attrs = v_c_attrs;
                c_enum_type = v_c_enum_type;
              } =
  let arg = v_class_type v_c_type in
  let arg = v_ident v_c_name in
  let arg = v_option v_type_params v_c_tparams in
  let arg = v_option v_extend v_c_extends in
  let arg = v_option v_interface v_c_implements in
  let arg = v_brace (v_list v_class_stmt) v_c_body in
  let arg = v_option v_attributes v_c_attrs in
  let arg = v_option v_enum_type v_c_enum_type in
  ()
  in
  vin.kclass_def (k, all_functions) x
and v_class_type =
  function
  | ClassRegular v1 -> let v1 = v_tok v1 in ()
  | ClassFinal ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_tok v2 in ()
  | ClassAbstract ((v1, v2)) -> let v1 = v_tok v1 and v2 = v_tok v2 in ()
  | Interface v1 -> let v1 = v_tok v1 in ()
  | Trait v1 -> let v1 = v_tok v1 in ()
  | Enum v1 -> let v1 = v_tok v1 in ()

and v_extend (v1, v2) =
  let v1 = v_tok v1 and v2 = v_fully_qualified_class_name v2 in ()
and v_interface (v1, v2) =
  let v1 = v_tok v1 and v2 = v_comma_list v_fully_qualified_class_name v2 in ()

and v_class_stmt x =
  let k x = match x with
  | TraitConstraint ((v1, v2, v3, v4)) ->
      let v1 = v_tok v1
      and v2 = v_wrap v_trait_constraint_kind v2
      and v3 = v_hint_type v3
      and v4 = v_tok v4
      in ()
  | ClassConstants ((v1, opt_ty, v2, v3)) ->
      let v1 = v_tok v1
      and opt_ty = v_option v_hint_type opt_ty
      and v2 = v_comma_list v_class_constant v2
      and v3 = v_tok v3
      in ()
  | ClassVariables ((v1, opt_ty, v2, v3)) ->
      let v1 = v_class_var_modifier v1
      and opt_ty = v_option v_hint_type opt_ty
      and v2 = v_comma_list v_class_variable v2
      and v3 = v_tok v3
      in ()
  | Method v1 -> let v1 = v_method_def v1 in ()
  | XhpDecl v1 ->
      let v1 = v_xhp_decl v1 in ()
  | UseTrait (v1, v2, v3) ->
      let v1 = v_tok v1 in
      let v2 = v_comma_list v_fully_qualified_class_name v2 in
      let v3 = Ocaml.v_either v_tok (v_brace (v_list v_trait_rule)) v3 in
      ()
  in
  vin.kclass_stmt (k, all_functions) x
and v_trait_constraint_kind =
  function | MustExtend -> () | MustImplement -> ()

and v_trait_rule =
  function
  | InsteadOf ((v1, v2, v3, v4, v5, v6)) ->
      let v1 = v_name v1
      and v2 = v_tok v2
      and v3 = v_ident v3
      and v4 = v_tok v4
      and v5 = v_comma_list v_class_name v5
      and v6 = v_tok v6
      in ()
  | As ((v1, v2, v3, v4, v5)) ->
      let v1 =
        Ocaml.v_either v_ident
          (fun (v1, v2, v3) ->
             let v1 = v_name v1 and v2 = v_tok v2 and v3 = v_ident v3 in ())
          v1
      and v2 = v_tok v2
      and v3 = v_list (v_wrap v_modifier) v3
      and v4 = v_option v_ident v4
      and v5 = v_tok v5
      in ()

and v_xhp_decl x =
    match x with
  | XhpAttributesDecl ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_comma_list v_xhp_attribute_decl v2
      and v3 = v_tok v3
      in ()
  | XhpChildrenDecl ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_xhp_children_decl v2
      and v3 = v_tok v3
      in ()
  | XhpCategoriesDecl ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_comma_list v_xhp_category_decl v2
      and v3 = v_tok v3
      in ()

and v_class_constant (v1, v2) =
  let v1 = v_ident v1 and v2 = v_static_scalar_affect v2 in ()
and v_class_var_modifier =
  function
  | NoModifiers v1 -> let v1 = v_tok v1 in ()
  | VModifiers v1 -> let v1 = v_list (v_wrap v_modifier) v1 in ()
and v_class_variable (v1, v2) =
  let v1 = v_dname v1 and v2 = v_option v_static_scalar_affect v2 in ()
and v_method_def x  =
  let k x = v_func_def x in
  vin.kmethod_def (k, all_functions) x

and v_modifier =
  function
  | Public -> ()
  | Private -> ()
  | Protected -> ()
  | Static -> ()
  | Abstract -> ()
  | Final -> ()
  | Async -> ()
and v_xhp_attribute_decl x =
  let k x = match x with
  | XhpAttrInherit v1 -> let v1 = v_xhp_tag_wrap v1 in ()
  | XhpAttrDecl ((v1, v2, v3, v4)) ->
      let v1 = v_xhp_attribute_type v1
      and v2 = v_xhp_attr_name v2
      and v3 = v_option v_xhp_value_affect v3
      and v4 = v_option v_tok v4
      in ()
  in
  vin.kxhp_attr_decl (k, all_functions) x

and v_xhp_attribute_type =
  function
  | XhpAttrType v1 -> let v1 = v_hint_type v1 in ()
  | XhpAttrVar v1 -> let v1 = v_tok v1 in ()
  | XhpAttrEnum ((v1, v2)) ->
      let v1 = v_tok v1 and v2 = v_brace (v_comma_list v_constant) v2 in ()
and v_xhp_value_affect (v1, v2) =
  let v1 = v_tok v1 and v2 = v_static_scalar v2 in ()


and v_xhp_children_decl x =
  let k x = match x with
  | XhpChild v1 -> let v1 = v_xhp_tag_wrap v1 in ()
  | XhpChildCategory v1 -> let v1 = v_xhp_tag_wrap v1 in ()
  | XhpChildAny v1 -> let v1 = v_tok v1 in ()
  | XhpChildEmpty v1 -> let v1 = v_tok v1 in ()
  | XhpChildPcdata v1 -> let v1 = v_tok v1 in ()
  | XhpChildSequence ((v1, v2, v3)) ->
      let v1 = v_xhp_children_decl v1
      and v2 = v_tok v2
      and v3 = v_xhp_children_decl v3
      in ()
  | XhpChildAlternative ((v1, v2, v3)) ->
      let v1 = v_xhp_children_decl v1
      and v2 = v_tok v2
      and v3 = v_xhp_children_decl v3
      in ()
  | XhpChildMul ((v1, v2)) ->
      let v1 = v_xhp_children_decl v1 and v2 = v_tok v2 in ()
  | XhpChildOption ((v1, v2)) ->
      let v1 = v_xhp_children_decl v1 and v2 = v_tok v2 in ()
  | XhpChildPlus ((v1, v2)) ->
      let v1 = v_xhp_children_decl v1 and v2 = v_tok v2 in ()
  | XhpChildParen v1 -> let v1 = v_paren v_xhp_children_decl v1 in ()
  in
  vin.kxhp_children_decl (k, all_functions) x

and v_xhp_category_decl v = v_xhp_tag_wrap v

and v_global_var =
  function
  | GlobalVar v1 -> let v1 = v_dname v1 in ()
  | GlobalDollar ((v1, v2)) ->
      let v1 = v_tok v1 and v2 = v_r_variable v2 in ()
  | GlobalDollarExpr ((v1, v2)) ->
      let v1 = v_tok v1 and v2 = v_brace v_expr v2 in ()
and v_static_var (v1, v2) =
  let v1 = v_dname v1 and v2 = v_option v_static_scalar_affect v2 in ()
and v_topstatement x = v_stmt x
and v_body x = v_brace (v_stmt_and_def_list_scope) x

and v_stmt_and_def_list_scope x =
  let k x =
    v_list v_topstatement x
  in
  vin.kstmt_and_def_list_scope (k, all_functions) x

and  v_constant_def {
                   cst_toks = v_cst_toks;
                   cst_name = v_cst_name;
                   cst_type = v_cst_type;
                   cst_val = v_cst_val
                 } =
  let arg =
    match v_cst_toks with
    | (v1, v2, v3) ->
        let v1 = v_tok v1 and v2 = v_tok v2 and v3 = v_tok v3 in () in
  let arg = v_ident v_cst_name in
  let arg = v_option v_hint_type v_cst_type in
  let arg = v_static_scalar v_cst_val in 
  ()

and v_attribute =
  function
  | Attribute v1 -> let v1 = v_wrap v_string v1 in ()
  | AttributeWithArgs ((v1, v2)) ->
      let v1 = v_wrap v_string v1
      and v2 = v_paren (v_comma_list v_static_scalar) v2
      in ()
and v_attributes v = v_angle (v_comma_list v_attribute) v

and
  v_type_def {
               t_tok = v_t_tok;
               t_name = v_t_name;
               t_tparams = v_t_tparams;
               t_tconstraint = v_t_tconstraint;
               t_tokeq = v_t_tokeq;
               t_kind = v_t_kind;
               t_sc = v_t_sc
             } =
  let arg = v_tok v_t_tok in
  let arg = v_ident v_t_name in
  let arg = v_option v_type_params v_t_tparams in
  let arg = v_option v_constraint v_t_tconstraint in
  let arg = v_tok v_t_tokeq in
  let arg = v_type_def_kind v_t_kind in let arg = v_tok v_t_sc in ()
and v_type_def_kind =
  function
  | Alias v1 -> let v1 = v_hint_type v1 in ()
  | Newtype v1 -> let v1 = v_hint_type v1 in ()
and v_namespace_use_rule =
  function
  | ImportNamespace v1 -> let v1 = v_qualified_ident v1 in ()
  | AliasNamespace ((v1, v2, v3)) ->
      let v1 = v_qualified_ident v1
      and v2 = v_tok v2
      and v3 = v_ident v3
      in ()

and v_toplevel x =
  let k x = match x with
  | StmtList v1 -> let v1 = v_list v_stmt v1 in ()
  | FuncDef v1 -> let v1 = v_func_def v1 in ()
  | ClassDef v1 -> let v1 = v_class_def v1 in ()
  | ConstantDef v1 -> let v1 = v_constant_def v1 in ()
  | TypeDef v1 -> let v1 = v_type_def v1 in ()
  | NotParsedCorrectly xs ->
      v_list v_info xs
  | FinalDef v1 ->
      v_info v1
  | NamespaceDef ((v1, v2, v3)) ->
      let v1 = v_tok v1 and v2 = v_qualified_ident v2 and v3 = v_tok v3 in ()
  | NamespaceBracketDef ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_option v_qualified_ident v2
      and v3 = v_brace (v_list v_toplevel) v3
      in ()
  | NamespaceUse ((v1, v2, v3)) ->
      let v1 = v_tok v1
      and v2 = v_comma_list v_namespace_use_rule v2
      and v3 = v_tok v3
      in ()
  in
  vin.ktop (k, all_functions) x

and v_program v = v_list v_toplevel v

and v_entity = function
  | FunctionE v1 -> let v1 = v_func_def v1 in ()
  | ClassE v1 -> let v1 = v_class_def v1 in ()
  | ConstantE v1 -> let v1 = v_constant_def v1 in ()
  | TypedefE v1 -> let v1 = v_type_def v1 in ()
  | StmtListE v1 -> let v1 = v_list v_stmt v1 in ()
  | MethodE v1 -> let v1 = v_method_def v1 in ()
  | ClassConstantE v1 -> let v1 = v_class_constant v1 in ()
  | ClassVariableE ((v1, v2)) ->
      let v1 = v_class_variable v1 and v2 = v_list v_modifier v2 in ()
  | XhpAttrE v1 -> let v1 = v_xhp_attribute_decl v1 in ()
  | MiscE v1 -> let v1 = v_list v_info v1 in ()

and v_any = function
  | Expr v1 -> let v1 = v_expr v1 in ()
  | Stmt2 v1 -> let v1 = v_stmt v1 in ()
  | Toplevel v1 -> let v1 = v_toplevel v1 in ()
  | Program v1 -> let v1 = v_program v1 in ()
  | Entity v1 -> let v1 = v_entity v1 in ()
  | Argument v1 -> let v1 = v_argument v1 in ()
  | Arguments v1 -> let v1 = (v_comma_list v_argument) v1 in ()
  | Parameter v1 -> let v1 = v_parameter v1 in ()
  | Parameters v1 -> let v1 = v_paren (v_comma_list_dots v_parameter) v1 in ()
  | ClassStmt v1 -> let v1 = v_class_stmt v1 in ()
  | ClassConstant2 v1 -> let v1 = v_class_constant v1 in ()
  | ClassVariable v1 -> let v1 = v_class_variable v1 in ()
  | Body v1 -> let v1 = v_brace (v_list v_topstatement) v1 in ()
  | StmtAndDefs v1 -> let v1 = v_list v_topstatement v1 in ()
  | ListAssign v1 -> let v1 = v_list_assign v1 in ()
  | XhpAttribute v1 -> let v1 = v_xhp_attribute v1 in ()
  | XhpAttrValue v1 -> let v1 = v_xhp_attr_value v1 in ()
  | XhpHtml2 v1 -> let v1 = v_xhp_html v1 in ()
  | XhpChildrenDecl2 v1 -> let v1 = v_xhp_children_decl v1 in ()
  | Info v1 -> let v1 = v_info v1 in ()
  | InfoList v1 -> let v1 = v_list v_info v1 in ()
  | ColonStmt2 v1 -> let v1 = v_colon_stmt v1 in ()
  | Case2 v1 -> let v1 = v_case v1 in ()
  | Ident2 v1 -> let v1 = v_ident v1 in ()
  | Hint2 v1 -> let v1 = v_hint_type v1 in ()

(* end of auto generation *)

and all_functions x = v_any x
in
  v_any

(*****************************************************************************)
(* Helpers *)
(*****************************************************************************)

let do_visit_with_ref mk_hooks = fun any ->
  let res = ref [] in
  let hooks = mk_hooks res in
  let vout = mk_visitor hooks in
  vout any;
  List.rev !res
