(**

 Ahrens, Lumsdaine, Voevodsky, 2015 - 2016

Main definitions:

- [families_precategory]
- [qq_structure_precategory]
*)

Require Import UniMath.CategoryTheory.limits.pullbacks.
Require Import UniMath.CategoryTheory.limits.more_on_pullbacks.

Require Import Systems.UnicodeNotations.
Require Import Systems.Auxiliary.
Require Import Systems.Structures.
Require UniMath.Ktheory.Precategories.
Require Import UniMath.Ktheory.StandardCategories.
Require Import Systems.CwF_SplitTypeCat_Maps.

Local Set Automatic Introduction.
(* only needed since imports globally unset it *)

Notation Precategory := Precategories.Precategory.
Coercion Precategories.Precategory_to_precategory
  : Precategories.Precategory >-> precategory.
Notation homset_property := Precategories.homset_property.
Notation functorPrecategory := Precategories.functorPrecategory.

(** Some local notations, *)

Local Notation "Γ ◂ A" := (comp_ext _ Γ A) (at level 30).
Local Notation "'Ty'" := (fun X Γ => (TY X : functor _ _) Γ : hSet) (at level 10).
Local Notation "'Tm'" := (fun Y Γ => (TM Y : functor _ _) Γ : hSet) (at level 10).
Local Notation Δ := comp_ext_compare.

Section fix_cat_obj_ext.

Variable C : Precategories.Precategory.
Definition hsC : has_homsets C := homset_property C.
Variable X : obj_ext_structure C.


(** * Precategory of families-structures *)
Section Families_Structure_Precat.

Local Notation "'Yo'" := (yoneda _ hsC).

Definition families_mor 
    (Y Y' : families_structure hsC X) 
  : UU
:= Σ FF_TM : TM Y --> TM Y',
       FF_TM ;; pp Y' = pp Y 
     × 
       Π {Γ:C} {A : Ty X Γ}, Q Y A ;; FF_TM =  Q Y' _.

Definition families_mor_TM {Y} {Y'} (FF : families_mor Y Y')
  : _ --> _
:= pr1 FF.

Definition families_mor_pp {Y} {Y'} (FF : families_mor Y Y')
  : families_mor_TM FF ;; pp Y' = pp Y 
:= pr1 (pr2 FF).

Definition families_mor_Q {Y} {Y'} (FF : families_mor Y Y')
    {Γ} A
  : _ = _
:= pr2 (pr2 FF) Γ A.

(* TODO: inline in [isaprop_families_mor]? *)
Lemma families_mor_eq {Y} {Y'} (FF FF' : families_mor Y Y')
    (e_TM : Π Γ (t : Tm Y Γ),
      (families_mor_TM FF : nat_trans _ _) _ t
      = (families_mor_TM FF' : nat_trans _ _) _ t)
  : FF = FF'.
Proof.
  apply subtypeEquality.
  - intros x; apply isapropdirprod.
    + apply functor_category_has_homsets.
    + repeat (apply impred_isaprop; intro). apply functor_category_has_homsets.
  - apply nat_trans_eq. apply has_homsets_HSET. 
    intros Γ. apply funextsec. unfold homot. apply e_TM.
Qed.


(* This is not full naturality of [term_to_section]; it is just what is required for [isaprop_families_mor] below. *)
Lemma term_to_section_naturality {Y} {Y'}
  {FY : families_mor Y Y'}
  {Γ : C} (t : Tm Y Γ) (A := (pp Y : nat_trans _ _) _ t)
  : pr1 (term_to_section ((families_mor_TM FY : nat_trans _ _) _ t))
  = pr1 (term_to_section t) 
   ;; Δ (!toforallpaths _ _ _ (nat_trans_eq_pointwise (families_mor_pp FY) Γ) t).
Proof.
  set (t' := (families_mor_TM FY : nat_trans _ _) _ t).
  set (A' := (pp Y' : nat_trans _ _) _ t').
  set (Pb := isPullback_preShv_to_pointwise hsC (isPullback_Q_pp Y' A') Γ);
    simpl in Pb.
  apply (pullback_HSET_elements_unique Pb); clear Pb.
  - unfold yoneda_morphisms_data; cbn.
    etrans. refine (pr2 (term_to_section t')). apply pathsinv0.
    etrans. Focus 2. refine (pr2 (term_to_section t)).
    etrans. apply @pathsinv0, assoc.
(*
    etrans. apply @pathsinv0, assoc.
*)
    apply maponpaths.
    apply comp_ext_compare_π.
(*
    etrans. Focus 2. apply @obj_ext_mor_ax.
    apply maponpaths. 
    apply comp_ext_compare_π.
*)
  - etrans. apply term_to_section_recover. apply pathsinv0.
    etrans. apply Q_comp_ext_compare.
    etrans. apply @pathsinv0.
      set (H1 := nat_trans_eq_pointwise (families_mor_Q FY A) Γ).
      exact (toforallpaths _ _ _ H1 _).
    cbn. apply maponpaths. apply term_to_section_recover.
Qed.

Lemma families_mor_recover_term  {Y} {Y'}
  {FY : families_mor Y Y'}
  {Γ : C} (t : Tm Y Γ)
  : (families_mor_TM FY : nat_trans _ _) Γ t
  = (Q Y' _ : nat_trans _ _) Γ (pr1 (term_to_section t) ).
Proof.
  etrans. apply @pathsinv0, term_to_section_recover.
  etrans. apply maponpaths, term_to_section_naturality.
  apply Q_comp_ext_compare.
Qed.

(* TODO: once all obligations proved, replace [families_mor_eq] with this in subsequent proofs. *)
Lemma isaprop_families_mor {Y} {Y'}
  : isaprop (families_mor Y Y').
Proof.
  apply invproofirrelevance; intros FF FF'. apply families_mor_eq.
  intros Γ t.
  etrans. apply families_mor_recover_term.
  apply @pathsinv0. apply families_mor_recover_term.
Qed.

(*
Lemma families_mor_transportf {X X'} {Y Y'}
    {F F' : X --> X'} (eF : F = F') (FF : families_mor Y Y' F)
    {Γ:C} (t : Tm Y Γ)
  : (families_mor_TM (transportf _ eF FF) : nat_trans _ _) Γ t
    = (families_mor_TM FF : nat_trans _ _) Γ t.
Proof.
  destruct eF. apply idpath.
Qed.
 *)

Definition families_ob_mor : precategory_ob_mor. (* disp_precat_ob_mor (obj_ext_Precat C). *)
Proof.
  exists (families_structure hsC X).
  exact @families_mor.
Defined.

Definition families_id_comp : precategory_id_comp families_ob_mor.
Proof.
  apply tpair.
  - intros Y. simpl; unfold families_mor.
    exists (identity _). apply tpair.
    + apply id_left. 
    + intros Γ A. apply id_right.
  - intros Y0 Y1 Y2 FF GG.
    exists (families_mor_TM FF ;; families_mor_TM GG). apply tpair.
    + etrans. apply @pathsinv0. apply assoc.
      etrans. apply maponpaths, families_mor_pp.
      apply families_mor_pp.
    + intros Γ A.
      etrans. apply assoc.
      etrans. apply cancel_postcomposition, families_mor_Q.
      apply families_mor_Q.
Defined.

Definition families_data : precategory_data 
  := (_ ,, families_id_comp).

Definition families_axioms : is_precategory families_data.
Proof.
  repeat apply tpair.
  - intros. apply families_mor_eq. intros.
    apply idpath.
  - intros. apply families_mor_eq. intros.
    apply idpath.
  - intros. apply families_mor_eq. intros.
    apply idpath.
Qed.


Definition families_precategory : precategory 
  := (_ ,, families_axioms).


Lemma has_homsets_families_precat 
  : has_homsets families_precategory.
Proof.
  intros a b. apply isaset_total2.
  apply functor_category_has_homsets.
  intros. apply isasetaprop, isapropdirprod.
  apply functor_category_has_homsets.
  repeat (apply impred_isaprop; intro). apply functor_category_has_homsets.
Qed.

End Families_Structure_Precat.

(** * Precategory of cartesian _q_-morphism-structures *)
Section qq_Structure_Precat.

Definition qq_structure_ob_mor : precategory_ob_mor.
Proof.
  exists (qq_morphism_structure X).
  intros Z Z'.
  refine (Π Γ' Γ (f : C ⟦ Γ' , Γ ⟧) (A : Ty X Γ), _).
  refine (qq Z f A  = _).
  refine (qq Z' f _ ).
Defined.

Lemma isaprop_qq_structure_mor
  (Z Z' : qq_structure_ob_mor)
  : isaprop (Z --> Z').
Proof.
  repeat (apply impred_isaprop; intro). apply hsC. 
Qed.

Definition qq_structure_id_comp : precategory_id_comp qq_structure_ob_mor.
Proof.
  apply tpair.
  - intros Z; cbn.
    intros Γ Γ' f A. apply idpath.
(*
    etrans. apply id_right.
    apply pathsinv0.
    etrans. apply @pathsinv0, assoc. 
    etrans. apply id_left.
    etrans.
      apply cancel_postcomposition.
      apply comp_ext_compare_id_general.
    apply id_left.
*)
  - intros Z0 Z1 Z2.
    intros FF GG Γ Γ' f A. cbn.
    etrans. apply FF. apply GG.
Qed.

Definition qq_structure_data : precategory_data 
  := (_ ,, qq_structure_id_comp).

Definition qq_structure_axioms : is_precategory qq_structure_data.
Proof.
  repeat apply tpair; intros;
    try apply isasetaprop; apply isaprop_qq_structure_mor.
Qed.

Definition qq_structure_precategory : precategory
  := (_ ,, qq_structure_axioms).

End qq_Structure_Precat.

Arguments qq_structure_precategory : clear implicits.

Section Compatible_Disp_Cat.

(* TODO: rename [strucs_compat_FOO] to [strucs_iscompat_FOO] throughout, to disambiguate these from the sigma’d displayed-precat [compat_structures]. *)

Definition strucs_compat_ob_mor
  : precategory_ob_mor.
Proof.
  use tpair.
  - exact (Σ YZ : (families_precategory × qq_structure_precategory), 
                  iscompatible_fam_qq (pr1 YZ) (pr2 YZ)).
  - 
    intros YZ YZ'.
    exact ((pr1 (pr1 YZ)) --> (pr1 (pr1 YZ')) × (pr2 (pr1 YZ)) --> pr2 (pr1 YZ')).
Defined.

Definition strucs_compat_id_comp
  : precategory_id_comp strucs_compat_ob_mor.
Proof.
  split. 
  - intro; split; apply identity.
  - intros a b c f g. split. 
    eapply @compose. apply (pr1 f). apply (pr1 g). 
    eapply @compose. apply (pr2 f). apply (pr2 g). 
Defined.

Definition strucs_compat_data : precategory_data 
  := ( _ ,, strucs_compat_id_comp).

Definition strucs_compat_axioms : is_precategory strucs_compat_data.
Proof.
  repeat apply tpair; intros.
  - apply dirprodeq;    apply id_left.
  - apply dirprodeq; apply id_right.
  - apply dirprodeq; apply assoc.
Qed.

Definition compat_structures_precategory
  : precategory 
:= ( _ ,, strucs_compat_axioms).

(* should this be the name of the compatible pairs category? *)
(*
Definition compat_structures_disp_precat
  := sigma_disp_precat strucs_compat_disp_precat.
*)


Definition compat_structures_pr1_functor
  : functor compat_structures_precategory families_precategory.
Proof.
  mkpair.
  - mkpair.
    + exact (fun YZp => pr1 (pr1 YZp)).
    + intros a b f. apply (pr1 f).
  - mkpair.
    + intro c. apply idpath.
    + intros a b c f g. apply idpath.
Defined.

Definition compat_structures_pr2_functor
  : functor compat_structures_precategory qq_structure_precategory.
Proof.
  mkpair.
  - mkpair.
    + exact (fun YZp => pr2 (pr1 YZp)).
    + intros a b f. apply (pr2 f).
  - mkpair.
    + intro c. apply idpath.
    + intros a b c f g. apply idpath.
Defined.


End Compatible_Disp_Cat.

