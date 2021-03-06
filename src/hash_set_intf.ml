open! Import

module type Accessors = sig
  include Container.Generic

  val mem : 'a t -> 'a -> bool (** override [Container.Generic.mem] *)

  val copy : 'a t -> 'a t      (** preserves the equality function *)

  val add               : 'a t -> 'a -> unit
  val strict_add        : 'a t -> 'a -> unit Or_error.t
  val strict_add_exn    : 'a t -> 'a -> unit
  val remove            : 'a t -> 'a -> unit
  val strict_remove     : 'a t -> 'a -> unit Or_error.t
  val strict_remove_exn : 'a t -> 'a -> unit
  val clear : 'a t -> unit
  val equal : 'a t -> 'a t -> bool
  val filter : 'a t -> f:('a -> bool) -> 'a t
  val filter_inplace : 'a t -> f:('a -> bool) -> unit

  (** [inter t1 t2] computes the set intersection of [t1] and [t2].  Runs in O(max(length
      t1, length t2)).  Behavior is undefined if [t1] and [t2] don't have the same
      equality function. *)
  val inter : 'key t -> 'key t -> 'key t
  val diff  : 'a   t -> 'a   t -> 'a   t

  val of_hashtbl_keys : ('a, _) Hashtbl.t -> 'a t
  val to_hashtbl : 'key t -> f:('key -> 'data) -> ('key, 'data) Hashtbl.t
end

type ('key, 'z) create_options_without_hashable =
  ('key, unit, 'z) Hashtbl_intf.create_options_without_hashable

type ('key, 'z) create_options_with_hashable_required =
  ('key, unit, 'z) Hashtbl_intf.create_options_with_hashable

type ('key, 'z) create_options_with_first_class_module =
  ('key, unit, 'z) Hashtbl_intf.create_options_with_first_class_module

module type Creators = sig
  type 'a t
  type 'a elt
  type ('a, 'z) create_options

  val create  : ('a, unit        -> 'a t) create_options
  val of_list : ('a, 'a elt list -> 'a t) create_options
end

module type Hash_set = sig

  type 'a t [@@deriving_inline sexp_of]
  include
  sig
    [@@@ocaml.warning "-32"]
    val sexp_of_t :
      ('a -> Ppx_sexp_conv_lib.Sexp.t) -> 'a t -> Ppx_sexp_conv_lib.Sexp.t
  end
  [@@@end]

  (** We use [[@@deriving_inline sexp_of][@@@end]] but not [[@@deriving sexp]] because we want people to be
      explicit about the hash and comparison functions used when creating hashtables.  One
      can use [Hash_set.Poly.t], which does have [[@@deriving_inline sexp][@@@end]], to use polymorphic
      comparison and hashing. *)

  module type Creators = Creators

  type nonrec ('key, 'z) create_options_with_first_class_module =
    ('key, 'z) create_options_with_first_class_module

  include Creators
    with type 'a t := 'a t
    with type 'a elt = 'a
    with type ('key, 'z) create_options := ('key, 'z) create_options_with_first_class_module (** @open *)

  module type Accessors = Accessors

  include Accessors with type 'a t := 'a t with type 'a elt := 'a elt (** @open *)

  val hashable_s : 'key t -> (module Hashtbl_intf.Key with type t = 'key)

  val hashable : 'key t -> 'key Hashtbl_intf.Hashable.t

  type nonrec ('key, 'z) create_options_without_hashable =
    ('key, 'z) create_options_without_hashable

  (** A hash set that uses polymorphic comparison *)
  module Poly : sig

    type nonrec 'a t = 'a t [@@deriving_inline sexp]
    include
    sig
      [@@@ocaml.warning "-32"]
      val t_of_sexp :
        (Ppx_sexp_conv_lib.Sexp.t -> 'a) -> Ppx_sexp_conv_lib.Sexp.t -> 'a t
      val sexp_of_t :
        ('a -> Ppx_sexp_conv_lib.Sexp.t) -> 'a t -> Ppx_sexp_conv_lib.Sexp.t
    end
    [@@@end]

    include Creators
      with type 'a t := 'a t
      with type 'a elt = 'a
      with type ('key, 'z) create_options := ('key, 'z) create_options_without_hashable

    include Accessors with type 'a t := 'a t with type 'a elt := 'a elt

  end

  (** [M] is meant to be used in combination with OCaml applicative functor types:

      {[
        type string_hash_set = Hash_set.M(String).t
      ]}

      which stands for:

      {[
        type string_hash_set = (String.t, int) Hash_set.t
      ]}

      The point is that [Hash_set.M(String).t] supports deriving, whereas the second
      syntax doesn't (because [t_of_sexp] doesn't know what comparison/hash function to
      use). *)
  module M (Elt : T.T) : sig
    type nonrec t = Elt.t t
  end
  module type Sexp_of_m = sig
    type t [@@deriving_inline sexp_of]
    include
    sig [@@@ocaml.warning "-32"] val sexp_of_t : t -> Ppx_sexp_conv_lib.Sexp.t
    end
    [@@@end]
  end
  module type M_of_sexp = sig
    type t [@@deriving_inline of_sexp]
    include
    sig [@@@ocaml.warning "-32"] val t_of_sexp : Ppx_sexp_conv_lib.Sexp.t -> t
    end
    [@@@end]
    include Hashtbl_intf.Key with type t := t
  end
  val sexp_of_m__t : (module Sexp_of_m with type t = 'elt) -> 'elt t -> Sexp.t
  val m__t_of_sexp : (module M_of_sexp with type t = 'elt) -> Sexp.t -> 'elt t

  module Creators (Elt : sig
      type 'a t
      val hashable : 'a t Hashtbl_intf.Hashable.t
    end) : sig
    type 'a t_ = 'a Elt.t t
    val t_of_sexp : (Sexp.t -> 'a Elt.t) -> Sexp.t -> 'a t_
    include Creators
      with type 'a t := 'a t_
      with type 'a elt := 'a Elt.t
      with type ('elt, 'z) create_options := ('elt, 'z) create_options_without_hashable
  end

  type nonrec ('key, 'z) create_options_with_hashable_required =
    ('key, 'z) create_options_with_hashable_required

  module Using_hashable : sig
    include Accessors with type 'a t = 'a t with type 'a elt := 'a elt
    include Creators
      with type 'a t := 'a t
      with type 'a elt = 'a
      with type ('key, 'z) create_options := ('key, 'z) create_options_with_hashable_required
  end
end
