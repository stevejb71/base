
(* [Sys0] defines functions that are primitives or can be simply defined in
   terms of [Caml.Sys].  [Sys0] is intended to completely express the part of
   [Caml.Sys] that [Base] uses -- no other file in Base other than sys.ml
   should use [Caml.Sys]. [Sys0] has few dependencies, and so is available
   early in Base's build order.  All Base files that need to use these
   functions and come before [Base.Sys] in build order should do
   [module Sys = Sys0].  Defining [module Sys = Sys0] is also necessary because
   it prevents ocamldep from mistakenly causing a file to depend on [Base.Sys]. *)

open! Import0

let interactive               = Caml.Sys.interactive
let os_type                   = Caml.Sys.os_type
let unix                      = Caml.Sys.unix
let win32                     = Caml.Sys.win32
let cygwin                    = Caml.Sys.cygwin

let word_size_in_bits         = Caml.Sys.word_size
let int_size_in_bits          = Caml.Sys.int_size
let big_endian                = Caml.Sys.big_endian
let max_string_length         = Caml.Sys.max_string_length
let max_array_length          = Caml.Sys.max_array_length
let runtime_variant           = Caml.Sys.runtime_variant
let runtime_parameters        = Caml.Sys.runtime_parameters

let argv                      = Caml.Sys.argv
let getenv                    = Caml.Sys.getenv

let ocaml_version             = Caml.Sys.ocaml_version
let enable_runtime_warnings   = Caml.Sys.enable_runtime_warnings
let runtime_warnings_enabled  = Caml.Sys.runtime_warnings_enabled

let opaque_identity           = Caml.Sys.opaque_identity

exception Break = Caml.Sys.Break
