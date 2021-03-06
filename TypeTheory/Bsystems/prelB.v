(** * Pre-lB-systems (unital)

By Vladimir Voevodsky, split off the file prelBsystems.v on March 3, 2015 *)



Require Import UniMath.Foundations.All.

Require Import TypeTheory.Csystems.hSet_ltowers.
Require Export TypeTheory.Bsystems.prelB_non_unital.
Require Export TypeTheory.Bsystems.dlt.




(** *** The structure formed by operations dlt *)


Definition dlt_layer_0 ( BB : lBsystem_carrier ) :=
  ∑ dlt : dlt_ops_type BB, dlt_ax0_type dlt.

Definition dlt_layer_0_to_dlt_ops_type ( BB : lBsystem_carrier ) :
  dlt_layer_0 BB -> dlt_ops_type BB := pr1 .
Coercion dlt_layer_0_to_dlt_ops_type : dlt_layer_0 >-> dlt_ops_type .


(** *** Complete definition of a (unital) pre-lB-system *)


Definition prelBsystem :=
  ∑ BB : prelBsystem_non_unital, dlt_layer_0 BB.

(** This definition adds exactly what Definition 2.2 adds in arXiv:1410.5389v1
    to a non-unital pre-B-system. *)

Definition prelBsystem_pr1 : prelBsystem -> prelBsystem_non_unital := pr1 . 
Coercion prelBsystem_pr1 : prelBsystem >-> prelBsystem_non_unital . 


(** *** Access functions for the operation dlt and its zeroth axiom *)


Definition dlt_op { BB : prelBsystem } : dlt_ops_type BB := pr2 BB . 

Definition dlt_ax0 { BB : prelBsystem } : dlt_ax0_type ( @dlt_op BB ) :=
  pr2 ( pr2 BB ) . 





(* End of the file prelB.v *)
