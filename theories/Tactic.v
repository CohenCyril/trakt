(*******************************************************************************)
(*                           *                     Trakt                       *)
(*  _______        _    _    *            Copyright (C) 2022 MERCE             *)
(* |__   __|      | |  | |   *     (Mitsubishi Electric R&D Centre Europe)     *)
(*    | |_ __ __ _| | _| |_  *        Enzo Crance <enzo.crance@inria.fr>       *)
(*    | | '__/ _` | |/ / __| ***************************************************)
(*    | | | | (_| |   <| |_  * This file is distributed under the terms of the *)
(*    |_|_|  \__,_|_|\_\\__| *   GNU Lesser General Public License Version 3   *)
(*                           *  (see LICENSE file for the text of the license) *)
(*******************************************************************************)

From elpi Require Import elpi.

From Trakt Require Import InternalProofs.
From Trakt Require Export Database.

Elpi Tactic trakt.

Elpi Accumulate File "elpi/types.elpi".
Elpi Accumulate Db embeddings.db.
Elpi Accumulate Db logic.db.
Elpi Accumulate Db symbols.db.
Elpi Accumulate Db relations.db.
Elpi Accumulate Db conversion.db.
Elpi Accumulate File "elpi/common.elpi".
Elpi Accumulate File "elpi/proof.elpi".
Elpi Accumulate File "elpi/rewrite-identities.elpi".
Elpi Accumulate File "elpi/preprocess.elpi".
Elpi Accumulate File "elpi/generalise-free-variables.elpi".
Elpi Accumulate File "elpi/bool-to-prop.elpi".
Elpi Accumulate File "elpi/tactic.elpi".
Elpi Accumulate lp:{{
  pred format-runtime-relation i:term, o:prop.

  format-runtime-relation RRD1 RRC1 :-
    coq.unify-leq RRD1 {{ pair (pair lp:R lp:R') lp:Proof) }} ok,
    coq.elaborate-skeleton R T RE ok,
    coq.elaborate-skeleton R' T' RE' ok,
    coq.elaborate-skeleton Proof _ ProofE ok,
    make-fun-type T (pr OutT [T1|_]),
    make-fun-type T' (pr OutT' [T1'|_]),
    RRC1 = relation RE T1 OutT RE' T1' OutT' ProofE.


  pred format-runtime-relation-data i:term, o:(list prop).

  format-runtime-relation-data RRDS [RRC1|RRC] :-
    coq.unify-leq RRDS {{ pair lp:RRD lp:RRD1 }} ok,
    format-runtime-relation RRD1 RRC1,
    !,
    format-runtime-relation-data RRD RRC.

  format-runtime-relation-data RRD1 [RRC1] :-
    format-runtime-relation RRD1 RRC1.


  solve InitialGoal NewGoals :-
    InitialGoal = goal Context _ InitialGoalTy _ [trm ETarget, trm LTarget, trm RuntimeRelData],
    (LTarget = {{ Prop }} ; LTarget = {{ bool }}), !,
    format-runtime-relation-data RuntimeRelData RuntimeRelCtx,
    RuntimeRelCtx =>
      preprocess-extra InitialGoalTy Context ETarget LTarget covariant true EndGoalTy Proof,
      refine {{ lp:Proof (_ : lp:EndGoalTy) }} InitialGoal NewGoals.

  solve InitialGoal NewGoals :-
    InitialGoal = goal Context _ InitialGoalTy _ [trm ETarget, trm LTarget],
    (LTarget = {{ Prop }} ; LTarget = {{ bool }}), !,
    [] =>
      preprocess-extra InitialGoalTy Context ETarget LTarget covariant true EndGoalTy Proof,
      refine {{ lp:Proof (_ : lp:EndGoalTy) }} InitialGoal NewGoals.

  solve _ _ :-
    coq.error "usage: trakt <target embedding type> <bool|Prop> [with rel <relations>]".
}}.
Elpi Typecheck.

Tactic Notation
  "trakt" constr(target) constr(logic_target) "with" "rel" constr(l) :=
    elpi trakt ltac_term:(target) ltac_term:(logic_target) ltac_term:(l).

Tactic Notation "trakt" constr(target) constr(logic_target) :=
  elpi trakt ltac_term:(target) ltac_term:(logic_target).

Elpi Tactic trakt_pose.

Elpi Accumulate File "elpi/types.elpi".
Elpi Accumulate Db embeddings.db.
Elpi Accumulate Db logic.db.
Elpi Accumulate Db symbols.db.
Elpi Accumulate Db relations.db.
Elpi Accumulate Db conversion.db.
Elpi Accumulate File "elpi/common.elpi".
Elpi Accumulate File "elpi/proof.elpi".
Elpi Accumulate File "elpi/rewrite-identities.elpi".
Elpi Accumulate File "elpi/preprocess.elpi".
Elpi Accumulate File "elpi/generalise-free-variables.elpi".
Elpi Accumulate File "elpi/bool-to-prop.elpi".
Elpi Accumulate File "elpi/tactic.elpi".
Elpi Accumulate lp:{{
  pred format-runtime-relation-data i:(list argument), o:(list prop).

  format-runtime-relation-data [RRD1|RRD] [RRC1|RRC] :-
    !, RRD1 = trm {{ pair (pair lp:R lp:R') lp:Proof }},
    coq.elaborate-skeleton R T RE ok,
    coq.elaborate-skeleton R' T' RE' ok,
    coq.elaborate-skeleton Proof _ ProofE ok,
    make-fun-type T (pr OutT [T1|_]),
    make-fun-type T' (pr OutT' [T1'|_]),
    RRC1 = relation RE T1 OutT RE' T1' OutT' ProofE,
    format-runtime-relation-data RRD RRC.

  format-runtime-relation-data [] [].

  solve Goal NewGoals :-
    Goal = goal _ _ GoalTy _ [trm ETarget, trm LTarget, trm H, str S|RuntimeRelData],
    (LTarget = {{ Prop }} ; LTarget = {{ bool }}),
    (H = global _ ; def H _ _ _ ; decl H _ _), !,
    coq.string->name S Name,
    format-runtime-relation-data RuntimeRelData RuntimeRelCtx,
    coq.typecheck H T ok,
    RuntimeRelCtx =>
      preprocess-extra T [] ETarget LTarget contravariant false T' P,
      refine (let Name T' (app [P, H]) (t\ {{ _ : lp:GoalTy }})) Goal NewGoals.
  
  solve _ _ :-
    coq.error {std.string.concat "\n" [
      "usage:",
      "  trakt_pose <target embedding type> <bool|Prop> :",
      "             <source constant> as <name for preprocessed term>",
      "             [with rel <relations>]"
    ]}.
}}.
Elpi Typecheck.

Tactic Notation "trakt_pose" constr(et) constr(lt) ":" constr(h) "as" ident(s) :=
  elpi trakt_pose ltac_term:(et) ltac_term:(lt) ltac_term:(h) ltac_string:(s).

Tactic Notation "trakt_pose"
  constr(et) constr(lt) ":" constr(h) "as" ident(s) "with" "rel" uconstr_list_sep(l, ",") :=
    elpi trakt_pose ltac_term:(et) ltac_term:(lt) ltac_term:(h) ltac_string:(s) ltac_term_list:(l).

Elpi Tactic trakt_boolify_arrows.

Elpi Accumulate File "elpi/types.elpi".
Elpi Accumulate Db logic.db.
Elpi Accumulate File "elpi/common.elpi".
Elpi Accumulate File "elpi/proof.elpi".
Elpi Accumulate File "elpi/boolify-arrows.elpi".
Elpi Accumulate lp:{{
  solve ((goal _ _ GoalTy _ []) as InitialGoal) NewGoals :- !, std.do! [
    coq.elaborate-skeleton GoalTy _ EGoalTy ok,
    boolify-arrows EGoalTy covariant true GoalTy' Proof,
    build Proof CoqProof,
    refine {{ lp:CoqProof (_ : lp:GoalTy') }} InitialGoal NewGoals
  ].

  solve _ _ :-
    coq.error "usage: trakt_boolify_arrows.".
}}.
Elpi Typecheck.

Tactic Notation "trakt_boolify_arrows" := elpi trakt_boolify_arrows.

Elpi Tactic trakt_reorder_quantifiers.

Elpi Accumulate File "elpi/types.elpi".
Elpi Accumulate File "elpi/common.elpi".
Elpi Accumulate File "elpi/reorder-quantifiers.elpi".
Elpi Accumulate lp:{{
  solve ((goal _ _ GoalTy _ []) as InitialGoal) NewGoals :- !, std.do! [
    coq.elaborate-skeleton GoalTy _ EGoalTy ok,
    reorder-goal EGoalTy Proof,
    coq.elaborate-skeleton Proof _ EProof ok,
    refine {{ lp:EProof _ }} InitialGoal NewGoals
  ].

  solve _ _ :-
    coq.error "usage: trakt_reorder_quantifiers.".
}}.
Elpi Typecheck.

Tactic Notation "trakt_reorder_quantifiers" := elpi trakt_reorder_quantifiers.
