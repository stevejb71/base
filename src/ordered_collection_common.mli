(** Functions for ordered collections. *)

open! Import

(** [normalize length_fun thing_with_length i] is just [i], unless [i] is negative, in
    which case it's [length_fun thing_with_length + i].  This is used by various
    Python-style slice functions. *)
val normalize : length_fun:('a -> int) -> 'a -> int -> int

val slice
  :  length_fun:('a -> int)
  -> sub_fun:('a -> pos:int -> len:int -> 'a)
  -> 'a
  -> int
  -> int
  -> 'a

(** [get_pos_len], [get_pos_len_exn], and [validate_pos_len_exn] are intended to be used
    by functions that take a sequence (array, string, bigstring, ...) and an optional
    [pos] and [len] specifying a subrange of the sequence.  Such functions should call
    [get_pos_len] with the length of the sequence and the optional [pos] and [len], and it
    will return the [pos] and [len] specifying the range, where the default [pos] is zero
    and the default [len] is to go to the end of the sequence.

    It should be the case that:

    {[
      pos >= 0 && len >= 0 && pos + len <= length
    ]}

    Note that this allows [pos = length] and [len = 0], i.e., an empty subrange
    at the end of the sequence.

    [get_pos_len] returns [(pos', len')] specifying a subrange where:

    {v
      pos' = match pos with None -> 0 | Some i -> i
      len' = match len with None -> length - pos | Some i -> i
    v} *)

val get_pos_len     : ?pos:int -> ?len:int -> length:int -> (int * int, string) Result.t
val get_pos_len_exn : ?pos:int -> ?len:int -> length:int -> int * int

(** [check_pos_len_exn ~pos ~len ~length] raises unless [pos >= 0 && len >= 0 && pos + len
    <= length]. *)
val check_pos_len_exn : pos:int -> len:int -> length:int -> unit

module Private : sig
  val slow_check_pos_len_exn : pos:int -> len:int -> length:int -> unit
end
