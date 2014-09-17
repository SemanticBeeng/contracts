Require Export Denotational.
Require Export Advance.

(********** Causality **********)

(* [obs_until d r1 r2] iff [r1] [r2] coincide at [d] and earlier. *)

Definition inp_until {A} (d : Z) (r1 r2 : inp A) : Prop :=
  forall z, Z.le z d -> r1 z = r2 z.

Definition env_until (d : Z) (e1 e2 : env) : Prop :=
  inp_until d (fst e1) (fst e2) /\ inp_until d (snd e1) (snd e2).


(* Semantic causality *)

Definition causal (c : contract) : Prop :=
  forall d r1 r2,  env_until (Z.of_nat d) r1 r2 -> (C[|c|]r1) d = (C[|c|]r2) d.


Lemma inp_until_adv {A} d t (r1 r2 : inp A): 
  inp_until d (adv_inp t r1) (adv_inp t r2) <-> inp_until (t + d) r1 r2.
Proof.
  split.
  unfold inp_until in *. intros.
  pose (H (z - t)%Z) as H'.
  unfold adv_inp in H'. 
  assert (t + (z - t) = z)%Z as E by omega.
  rewrite E in H'. apply H'. omega.

  unfold inp_until in *. intros.
  unfold adv_inp. 

  pose (H (t + z)%Z) as H'.  apply H'. omega.

Qed.

Lemma env_until_adv d t e1 e2: 
    env_until d (adv_env t e1) (adv_env t e2) <-> env_until (t + d) e1 e2.
Proof.
  unfold env_until. repeat rewrite adv_env_obs. repeat rewrite adv_env_ch.
  repeat rewrite inp_until_adv. reflexivity.
Qed.

Lemma env_until_adv_1 d r1 r2 : (1 <= d -> env_until d r1 r2 ->
                        env_until (d - 1) (adv_env 1 r1) (adv_env 1 r2))%Z.
Proof.
  intros.
  assert (1 + (d - 1) = d)%Z by omega.
  rewrite env_until_adv. rewrite H1. assumption.
Qed.
