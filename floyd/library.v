Require Import VST.floyd.base2.
Require Import VST.floyd.sublist.
Require Import VST.floyd.client_lemmas.
Require Import VST.floyd.closed_lemmas.
Require Import VST.floyd.compare_lemmas.
Require Import VST.floyd.semax_tactics.
Require Import VST.floyd.forward.
Require Import VST.floyd.call_lemmas.
Require Import VST.floyd.forward_lemmas.
Require Import VST.floyd.for_lemmas.
Require Import VST.floyd.nested_pred_lemmas.
Require Import VST.floyd.nested_field_lemmas.
Require Import VST.floyd.efield_lemmas.
Require Import VST.floyd.mapsto_memory_block.
Require Import VST.floyd.aggregate_type.
Require VST.floyd.aggregate_pred. Import VST.floyd.aggregate_pred.aggregate_pred.
Require Import VST.floyd.reptype_lemmas.
Require Import VST.floyd.data_at_rec_lemmas.
Require Import VST.floyd.field_at.
Require Import VST.floyd.field_compat.
Require Import VST.floyd.stronger.
Require Import VST.floyd.loadstore_mapsto.
Require Import VST.floyd.loadstore_field_at.
Require Import VST.floyd.nested_loadstore.
Require Import VST.floyd.local2ptree_denote.
Require Import VST.floyd.local2ptree_eval.
Require Import VST.floyd.proj_reptype_lemmas.
Require Import VST.floyd.replace_refill_reptype_lemmas.
Require Import VST.floyd.sc_set_load_store.
(*Require Import VST.floyd.unfold_data_at.*)
Require Import VST.floyd.entailer.
Require Import VST.floyd.globals_lemmas.
Require Import VST.floyd.diagnosis.
Require Import VST.floyd.freezer.
Import ListNotations.
Import String.

Definition body_lemma_of_funspec  {Espec: OracleKind} (ef: external_function) (f: funspec) :=
  match f with mk_funspec sig _ A P Q _ _ =>
    semax_external (map fst (fst sig)) ef A P Q
  end.

Definition try_spec (prog: program) (name: string) (spec: funspec) : list (ident*funspec) :=
 match ext_link_prog' (prog_defs prog) name with
 | Some id => [(id,spec)]
 | None => nil
 end.
Arguments try_spec prog name spec / .

Definition exit_spec' :=
 WITH u: unit
 PRE [1%positive OF tint]
   PROP () LOCAL() SEP()
 POST [ tvoid ]
   PROP(False) LOCAL() SEP().

Definition exit_spec (prog: program) := try_spec prog "exit" exit_spec'.
Arguments exit_spec prog / .

Parameter body_exit:
 forall {Espec: OracleKind},
  body_lemma_of_funspec
    (EF_external "exit"
       {| sig_args := AST.Tint :: nil; sig_res := None; sig_cc := cc_default |})
   exit_spec'.

Parameter malloc_token : forall {cs: compspecs}, share -> type -> val -> mpred.
Parameter malloc_token_valid_pointer:
  forall {cs: compspecs} sh t p, malloc_token sh t p |-- valid_pointer p.
Hint Resolve malloc_token_valid_pointer : valid_pointer.
Parameter malloc_token_local_facts:
  forall {cs: compspecs} sh t p, malloc_token sh t p |-- !! malloc_compatible (sizeof t) p.
Hint Resolve malloc_token_local_facts : saturate_local.
Parameter malloc_token_precise:
  forall {cs: compspecs} sh t p, predicates_sl.precise (malloc_token sh t p).

Definition malloc_spec' :=
   WITH cs: compspecs, t:type
   PRE [ 1%positive OF tuint ]
       PROP (0 <= sizeof t <= Int.max_unsigned;
                complete_legal_cosu_type t = true;
                natural_aligned natural_alignment t = true)
       LOCAL (temp 1%positive (Vint (Int.repr (sizeof t))))
       SEP ()
    POST [ tptr tvoid ] EX p:_,
       PROP ()
       LOCAL (temp ret_temp p)
       SEP (if eq_dec p nullval then emp
            else (malloc_token Tsh t p * data_at_ Tsh t p)).

Definition malloc_spec (prog: program) :=
   try_spec prog "_malloc" malloc_spec'.
Arguments malloc_spec prog / .

Parameter body_malloc:
 forall {Espec: OracleKind},
  body_lemma_of_funspec EF_malloc malloc_spec'.

Definition free_spec' :=
   WITH cs: compspecs, t: type, p:val
   PRE [ 1%positive OF tptr tvoid ]
       PROP ()
       LOCAL (temp 1%positive p)
       SEP (malloc_token Tsh t p; data_at_ Tsh t p)
    POST [ Tvoid ]
       PROP ()
       LOCAL ()
       SEP ().

Definition free_spec  (prog: program) :=
   try_spec prog "_free" free_spec'.
Arguments free_spec prog / .

Parameter body_free:
 forall {Espec: OracleKind},
  body_lemma_of_funspec EF_free free_spec'.

Definition library_G prog :=
  exit_spec prog ++ malloc_spec prog ++ free_spec prog.

Ltac with_library prog G := 
 let x := constr:(library_G prog) in
 let x := eval hnf in x in 
 let x := eval simpl in x in
 let y := constr:(x++G) in
 let y := eval cbv beta iota delta [app] in y in 
 with_library' prog y.

Lemma semax_func_cons_malloc_aux:
  forall {cs: compspecs} (gx : genviron) (t :type) (ret : option val),
(EX p : val,
 PROP ( )
 LOCAL (temp ret_temp p)
 SEP (if eq_dec p nullval
      then emp
      else malloc_token Tsh t p * data_at_ Tsh t p))%assert
  (make_ext_rval gx ret) |-- !! is_pointer_or_null (force_val ret).
Proof.
 intros.
 rewrite exp_unfold. Intros p.
 rewrite <- insert_local.
 rewrite lower_andp.
 apply derives_extract_prop; intro. hnf in H. rewrite retval_ext_rval in H.
 subst p.
 if_tac. rewrite H; entailer!.
 renormalize. entailer!.
Qed.
