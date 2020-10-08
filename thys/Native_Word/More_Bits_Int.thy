(*  Title:      Bits_Int.thy
    Author:     Andreas Lochbihler, ETH Zurich
*)

chapter \<open>More bit operations on integers\<close>

theory More_Bits_Int
imports
  "HOL-Word.Bits_Int"
  "HOL-Word.Bit_Comprehension"
begin

text \<open>Preliminaries\<close>

lemma last_rev' [simp]: "last (rev xs) = hd xs" \<comment> \<open>TODO define \<open>last []\<close> as \<open>hd []\<close>?\<close>
  by (cases xs) (simp add: last_def hd_def, simp)

lemma nat_LEAST_True: "(LEAST _ :: nat. True) = 0"
  by (rule Least_equality) simp_all

text \<open>
  Use this function to convert numeral @{typ integer}s quickly into @{typ int}s.
  By default, it works only for symbolic evaluation; normally generated code raises
  an exception at run-time. If theory \<open>Code_Target_Bits_Int\<close> is imported,
  it works again, because then @{typ int} is implemented in terms of @{typ integer}
  even for symbolic evaluation.
\<close>

definition int_of_integer_symbolic :: "integer \<Rightarrow> int"
  where "int_of_integer_symbolic = int_of_integer"

lemma int_of_integer_symbolic_aux_code [code nbe]:
  "int_of_integer_symbolic 0 = 0"
  "int_of_integer_symbolic (Code_Numeral.Pos n) = Int.Pos n"
  "int_of_integer_symbolic (Code_Numeral.Neg n) = Int.Neg n"
  by (simp_all add: int_of_integer_symbolic_def)

code_identifier
  code_module Bits_Int \<rightharpoonup>
  (SML) Bit_Operations and (OCaml) Bit_Operations and (Haskell) Bit_Operations and (Scala) Bit_Operations
| code_module More_Bits_Int \<rightharpoonup>
  (SML) Bit_Operations and (OCaml) Bit_Operations and (Haskell) Bit_Operations and (Scala) Bit_Operations
| constant take_bit \<rightharpoonup>
  (SML) Bit_Operations.take_bit and (OCaml) Bit_Operations.take_bit and (Haskell) Bit_Operations.take_bit and (Scala) Bit_Operations.take_bit


section \<open>Symbolic bit operations on numerals and @{typ int}s\<close>

fun bitOR_num :: "num \<Rightarrow> num \<Rightarrow> num"
where
  "bitOR_num num.One num.One = num.One"
| "bitOR_num num.One (num.Bit0 n) = num.Bit1 n"
| "bitOR_num num.One (num.Bit1 n) = num.Bit1 n"
| "bitOR_num (num.Bit0 m) num.One = num.Bit1 m"
| "bitOR_num (num.Bit0 m) (num.Bit0 n) = num.Bit0 (bitOR_num m n)"
| "bitOR_num (num.Bit0 m) (num.Bit1 n) = num.Bit1 (bitOR_num m n)"
| "bitOR_num (num.Bit1 m) num.One = num.Bit1 m"
| "bitOR_num (num.Bit1 m) (num.Bit0 n) = num.Bit1 (bitOR_num m n)"
| "bitOR_num (num.Bit1 m) (num.Bit1 n) = num.Bit1 (bitOR_num m n)"

fun bitAND_num :: "num \<Rightarrow> num \<Rightarrow> num option"
where
  "bitAND_num num.One num.One = Some num.One"
| "bitAND_num num.One (num.Bit0 n) = None"
| "bitAND_num num.One (num.Bit1 n) = Some num.One"
| "bitAND_num (num.Bit0 m) num.One = None"
| "bitAND_num (num.Bit0 m) (num.Bit0 n) = map_option num.Bit0 (bitAND_num m n)"
| "bitAND_num (num.Bit0 m) (num.Bit1 n) = map_option num.Bit0 (bitAND_num m n)"
| "bitAND_num (num.Bit1 m) num.One = Some num.One"
| "bitAND_num (num.Bit1 m) (num.Bit0 n) = map_option num.Bit0 (bitAND_num m n)"
| "bitAND_num (num.Bit1 m) (num.Bit1 n) = (case bitAND_num m n of None \<Rightarrow> Some num.One | Some n' \<Rightarrow> Some (num.Bit1 n'))"

fun bitXOR_num :: "num \<Rightarrow> num \<Rightarrow> num option"
where
  "bitXOR_num num.One num.One = None"
| "bitXOR_num num.One (num.Bit0 n) = Some (num.Bit1 n)"
| "bitXOR_num num.One (num.Bit1 n) = Some (num.Bit0 n)"
| "bitXOR_num (num.Bit0 m) num.One = Some (num.Bit1 m)"
| "bitXOR_num (num.Bit0 m) (num.Bit0 n) = map_option num.Bit0 (bitXOR_num m n)"
| "bitXOR_num (num.Bit0 m) (num.Bit1 n) = Some (case bitXOR_num m n of None \<Rightarrow> num.One | Some n' \<Rightarrow> num.Bit1 n')"
| "bitXOR_num (num.Bit1 m) num.One = Some (num.Bit0 m)"
| "bitXOR_num (num.Bit1 m) (num.Bit0 n) = Some (case bitXOR_num m n of None \<Rightarrow> num.One | Some n' \<Rightarrow> num.Bit1 n')"
| "bitXOR_num (num.Bit1 m) (num.Bit1 n) = map_option num.Bit0 (bitXOR_num m n)"

fun bitORN_num :: "num \<Rightarrow> num \<Rightarrow> num"
where
  "bitORN_num num.One num.One = num.One"
| "bitORN_num num.One (num.Bit0 m) = num.Bit1 m"
| "bitORN_num num.One (num.Bit1 m) = num.Bit1 m"
| "bitORN_num (num.Bit0 n) num.One = num.Bit0 num.One"
| "bitORN_num (num.Bit0 n) (num.Bit0 m) = Num.BitM (bitORN_num n m)"
| "bitORN_num (num.Bit0 n) (num.Bit1 m) = num.Bit0 (bitORN_num n m)"
| "bitORN_num (num.Bit1 n) num.One = num.One"
| "bitORN_num (num.Bit1 n) (num.Bit0 m) = Num.BitM (bitORN_num n m)"
| "bitORN_num (num.Bit1 n) (num.Bit1 m) = Num.BitM (bitORN_num n m)"

fun bitANDN_num :: "num \<Rightarrow> num \<Rightarrow> num option"
where
  "bitANDN_num num.One num.One = None"
| "bitANDN_num num.One (num.Bit0 n) = Some num.One"
| "bitANDN_num num.One (num.Bit1 n) = None"
| "bitANDN_num (num.Bit0 m) num.One = Some (num.Bit0 m)"
| "bitANDN_num (num.Bit0 m) (num.Bit0 n) = map_option num.Bit0 (bitANDN_num m n)"
| "bitANDN_num (num.Bit0 m) (num.Bit1 n) = map_option num.Bit0 (bitANDN_num m n)"
| "bitANDN_num (num.Bit1 m) num.One = Some (num.Bit0 m)"
| "bitANDN_num (num.Bit1 m) (num.Bit0 n) = (case bitANDN_num m n of None \<Rightarrow> Some num.One | Some n' \<Rightarrow> Some (num.Bit1 n'))"
| "bitANDN_num (num.Bit1 m) (num.Bit1 n) = map_option num.Bit0 (bitANDN_num m n)"

lemma int_numeral_bitOR_num: "numeral n OR numeral m = (numeral (bitOR_num n m) :: int)"
by(induct n m rule: bitOR_num.induct) simp_all

lemma int_numeral_bitAND_num: "numeral n AND numeral m = (case bitAND_num n m of None \<Rightarrow> 0 :: int | Some n' \<Rightarrow> numeral n')"
by(induct n m rule: bitAND_num.induct)(simp_all split: option.split)

lemma int_numeral_bitXOR_num:
  "numeral m XOR numeral n = (case bitXOR_num m n of None \<Rightarrow> 0 :: int | Some n' \<Rightarrow> numeral n')"
by(induct m n rule: bitXOR_num.induct)(simp_all split: option.split)

lemma int_or_not_bitORN_num:
  "numeral n OR NOT (numeral m) = (- numeral (bitORN_num n m) :: int)"
  by (induction n m rule: bitORN_num.induct) (simp_all add: add_One BitM_inc_eq)

lemma int_and_not_bitANDN_num:
  "numeral n AND NOT (numeral m) = (case bitANDN_num n m of None \<Rightarrow> 0 :: int | Some n' \<Rightarrow> numeral n')"
  by (induction n m rule: bitANDN_num.induct) (simp_all add: add_One BitM_inc_eq split: option.split)

lemma int_not_and_bitANDN_num:
  "NOT (numeral m) AND numeral n = (case bitANDN_num n m of None \<Rightarrow> 0 :: int | Some n' \<Rightarrow> numeral n')"
by(simp add: int_and_not_bitANDN_num[symmetric] int_and_comm)


section \<open>Bit masks of type \<^typ>\<open>int\<close>\<close>

lemma bin_mask_conv_pow2:
  "mask n = 2 ^ n - (1 :: int)"
  by (fact mask_eq_exp_minus_1)
  
lemma bin_mask_ge0: "mask n \<ge> (0 :: int)"
  by (fact mask_nonnegative_int)

lemma and_bin_mask_conv_mod: "x AND mask n = x mod 2 ^ n"
  for x :: int
  by (simp flip: take_bit_eq_mod add: take_bit_eq_mask)

lemma bin_mask_numeral: 
  "mask (numeral n) = (1 :: int) + 2 * mask (pred_numeral n)"
  by (fact mask_numeral)

lemma bin_nth_mask [simp]: "bit (mask n :: int) i \<longleftrightarrow> i < n"
  by (simp add: bit_mask_iff)

lemma bin_sign_mask [simp]: "bin_sign (mask n) = 0"
  by (simp add: bin_sign_def bin_mask_conv_pow2)

lemma bin_mask_p1_conv_shift: "mask n + 1 = (1 :: int) << n"
  by (simp add: bin_mask_conv_pow2 shiftl_int_def)

end
