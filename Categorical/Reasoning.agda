{-# OPTIONS --safe --without-K #-}

-- Utilities for reasoning about morphism equivalence.

-- Inspired by Categories.Morphism.Reasoning in agda-categories. Quoting that
-- module:

{-
  Helper routines most often used in reasoning with commutative squares,
  at the level of arrows in categories.

  Basic  : reasoning about identity
  Pulls  : use a ∘ b ≈ c as left-to-right rewrite
  Pushes : use c ≈ a ∘ b as a left-to-right rewrite
  IntroElim : introduce/eliminate an equivalent-to-id arrow
  Extend : 'extends' a commutative square with an equality on left/right/both
-}

open import Categorical.Equiv
open import Categorical.Raw
open import Categorical.Laws as L
       hiding (Category; Cartesian; CartesianClosed)

module Categorical.Reasoning
    {o}{obj : Set o} {ℓ} {_⇨_ : obj → obj → Set ℓ} ⦃ _ : Category _⇨_ ⦄
    {q} ⦃ _ : Equivalent q _⇨_ ⦄ ⦃ _ : L.Category _⇨_ ⦄
  where

open import Level
open import Function using (_∘′_)

private
  variable
    a b c d e : obj
    a′ b′ c′ d′ e′ : obj
    f g h i j k : a ⇨ b

open import Categorical.Equiv  public
open ≈-Reasoning

module Misc where

  sym-sym : {i j : a ⇨ b} {f g : c ⇨ d} → (i ≈ j → f ≈ g) → (j ≈ i → g ≈ f)
  sym-sym f≈g = sym ∘′ f≈g ∘′ sym
  -- sym-sym f≈g i≈j = sym (f≈g (sym i≈j))

  -- I've been able to use sym-sym, due to implicits

open Misc public


module Pulls {i : b ⇨ c}{j : c ⇨ d}{k : b ⇨ d} (j∘i≈k : j ∘ i ≈ k) where

  pullˡ : {f : a ⇨ b} → j ∘ i ∘ f ≈ k ∘ f
  pullˡ {f = f} = begin
                    j ∘ (i ∘ f)
                  ≈⟨ ∘-assocˡ ⟩
                    (j ∘ i) ∘ f
                  ≈⟨ ∘≈ˡ j∘i≈k ⟩
                    k ∘ f
                  ∎

  pullʳ : {f : d ⇨ e} → (f ∘ j) ∘ i ≈ f ∘ k
  pullʳ {f = f} = begin
                    (f ∘ j) ∘ i
                  ≈⟨ ∘-assocʳ ⟩
                    f ∘ (j ∘ i)
                  ≈⟨ ∘≈ʳ j∘i≈k ⟩
                    f ∘ k
                  ∎

open Pulls public


module Pushes {i : b ⇨ c}{j : c ⇨ d}{k : b ⇨ d} (k≈j∘i : k ≈ j ∘ i) where

  private j∘i≈k = sym k≈j∘i

  pushˡ : {f : a ⇨ b} → k ∘ f ≈ j ∘ i ∘ f
  pushˡ = sym (pullˡ j∘i≈k)

  pushʳ : {f : d ⇨ e} → f ∘ k ≈ (f ∘ j) ∘ i
  pushʳ = sym (pullʳ j∘i≈k)

open Pushes public


module IntroElim {i : b ⇨ b} (i≈id : i ≈ id) where

  elimˡ  : ∀ {f : a ⇨ b} → i ∘ f ≈ f
  elimˡ  {f = f} = begin
                     i ∘ f
                   ≈⟨ ∘≈ˡ i≈id ⟩
                     id ∘ f
                   ≈⟨ identityˡ ⟩
                     f
                   ∎

  introˡ : ∀ {f : a ⇨ b} → f ≈ i ∘ f
  introˡ = sym elimˡ

  elimʳ  : ∀ {f : b ⇨ c} → f ∘ i ≈ f
  elimʳ  {f = f} = begin
                     f ∘ i
                   ≈⟨ ∘≈ʳ i≈id ⟩
                     f ∘ id
                   ≈⟨ identityʳ ⟩
                     f
                   ∎

  introʳ : ∀ {f : b ⇨ c} → f ≈ f ∘ i
  introʳ = sym elimʳ

  intro-center : ∀ {f : a ⇨ b} {g : b ⇨ c} → g ∘ f ≈ g ∘ i ∘ f
  intro-center = ∘≈ʳ introˡ

  elim-center  : ∀ {f : a ⇨ b} {g : b ⇨ c} → g ∘ i ∘ f ≈ g ∘ f
  elim-center  = sym intro-center

open IntroElim public


module ∘-Assoc where

  -- TODO: Maybe move ∘-assocˡ′ and ∘-assocʳ′ to Pulls

  ∘-assocˡ′ : ∀ {f : a ⇨ b}{g : b ⇨ c}{h : c ⇨ d}{k : b ⇨ d}
            → h ∘ g ≈ k → h ∘ (g ∘ f) ≈ k ∘ f
  ∘-assocˡ′ h∘g≈k = ∘-assocˡ ; ∘≈ˡ h∘g≈k

  ∘-assocʳ′ : ∀ {f : a ⇨ b}{g : b ⇨ c}{h : a ⇨ c}{k : c ⇨ d}
            → g ∘ f ≈ h → (k ∘ g) ∘ f ≈ k ∘ h
  ∘-assocʳ′ g∘f≈h = ∘-assocʳ ; ∘≈ʳ g∘f≈h


  ∘-assocˡʳ′ : ∀ {f : a ⇨ b}{g : b ⇨ c}{h : c ⇨ d}{i : b ⇨ c′}{j : c′ ⇨ d}
             → h ∘ g ≈ j ∘ i → h ∘ (g ∘ f) ≈ j ∘ (i ∘ f)
  ∘-assocˡʳ′ h∘g≈j∘i = ∘-assocˡ′ h∘g≈j∘i ; ∘-assocʳ

  ∘-assocʳˡ′ : ∀ {f : a ⇨ b}{g : b ⇨ c}{h : c ⇨ d}{i : a ⇨ b′}{j : b′ ⇨ c}
             → g ∘ f ≈ j ∘ i → (h ∘ g) ∘ f ≈ (h ∘ j) ∘ i
  ∘-assocʳˡ′ g∘f≈j∘i = ∘-assocʳ′ g∘f≈j∘i ; ∘-assocˡ


  ∘-assoc-elimˡ : ∀ {f : a ⇨ b}{i : b ⇨ c}{j : c ⇨ b}
                → j ∘ i ≈ id → j ∘ (i ∘ f) ≈ f
  ∘-assoc-elimˡ {f = f}{i}{j} j∘i≈id = ∘-assocˡ ; elimˡ j∘i≈id

  ∘-assoc-elimʳ : ∀ {i : a ⇨ b}{j : b ⇨ a}{f : a ⇨ c}
                → j ∘ i ≈ id → (f ∘ j) ∘ i ≈ f
  ∘-assoc-elimʳ {i = i}{f}{j} j∘i≈id = ∘-assocʳ ; elimʳ j∘i≈id


  -- ∘-assocʳ² : {a₀ a₁ a₂ a₃ : obj}
  --          {f₁ : a₀ ⇨ a₁}{f₂ : a₁ ⇨ a₂}{f₃ : a₂ ⇨ a₃}
  --        → (f₃ ∘ f₂) ∘ f₁ ≈ f₃ ∘ f₂ ∘ f₁
  -- ∘-assocʳ² = ∘-assocʳ

  ∘-assocʳ³ : {a₀ a₁ a₂ a₃ a₄ : obj}
           {f₁ : a₀ ⇨ a₁}{f₂ : a₁ ⇨ a₂}{f₃ : a₂ ⇨ a₃}{f₄ : a₃ ⇨ a₄}
         → (f₄ ∘ f₃ ∘ f₂) ∘ f₁ ≈ f₄ ∘ f₃ ∘ f₂ ∘ f₁
  ∘-assocʳ³ = ∘≈ʳ ∘-assocʳ • ∘-assocʳ

  ∘-assocʳ⁴ : {a₀ a₁ a₂ a₃ a₄ a₅ : obj}
     {f₁ : a₀ ⇨ a₁}{f₂ : a₁ ⇨ a₂}{f₃ : a₂ ⇨ a₃}{f₄ : a₃ ⇨ a₄}{f₅ : a₄ ⇨ a₅}
   → (f₅ ∘ f₄ ∘ f₃ ∘ f₂) ∘ f₁ ≈ f₅ ∘ f₄ ∘ f₃ ∘ f₂ ∘ f₁
  ∘-assocʳ⁴ = ∘≈ʳ ∘-assocʳ³ • ∘-assocʳ

  ∘-assocʳ⁵ : {a₀ a₁ a₂ a₃ a₄ a₅ a₆ : obj}
     {f₁ : a₀ ⇨ a₁}{f₂ : a₁ ⇨ a₂}{f₃ : a₂ ⇨ a₃}{f₄ : a₃ ⇨ a₄}{f₅ : a₄ ⇨ a₅}{f₆ : a₅ ⇨ a₆}
   → (f₆ ∘ f₅ ∘ f₄ ∘ f₃ ∘ f₂) ∘ f₁ ≈ f₆ ∘ f₅ ∘ f₄ ∘ f₃ ∘ f₂ ∘ f₁
  ∘-assocʳ⁵ = ∘≈ʳ ∘-assocʳ⁴ • ∘-assocʳ

  ∘-assocˡ³ : {a₀ a₁ a₂ a₃ a₄ : obj}
           {f₁ : a₀ ⇨ a₁}{f₂ : a₁ ⇨ a₂}{f₃ : a₂ ⇨ a₃}{f₄ : a₃ ⇨ a₄}
         → f₄ ∘ f₃ ∘ f₂ ∘ f₁ ≈ (f₄ ∘ f₃ ∘ f₂) ∘ f₁
  ∘-assocˡ³ = sym ∘-assocʳ³

  ∘-assocˡ⁴ : {a₀ a₁ a₂ a₃ a₄ a₅ : obj}
     {f₁ : a₀ ⇨ a₁}{f₂ : a₁ ⇨ a₂}{f₃ : a₂ ⇨ a₃}{f₄ : a₃ ⇨ a₄}{f₅ : a₄ ⇨ a₅}
   → f₅ ∘ f₄ ∘ f₃ ∘ f₂ ∘ f₁ ≈ (f₅ ∘ f₄ ∘ f₃ ∘ f₂) ∘ f₁
  ∘-assocˡ⁴ = sym ∘-assocʳ⁴

  ∘-assocˡ⁵ : {a₀ a₁ a₂ a₃ a₄ a₅ a₆ : obj}
     {f₁ : a₀ ⇨ a₁}{f₂ : a₁ ⇨ a₂}{f₃ : a₂ ⇨ a₃}{f₄ : a₃ ⇨ a₄}{f₅ : a₄ ⇨ a₅}{f₆ : a₅ ⇨ a₆}
   → f₆ ∘ f₅ ∘ f₄ ∘ f₃ ∘ f₂ ∘ f₁ ≈ (f₆ ∘ f₅ ∘ f₄ ∘ f₃ ∘ f₂) ∘ f₁
  ∘-assocˡ⁵ = sym ∘-assocʳ⁵

open ∘-Assoc public


module Assoc
  ⦃ _ : Products obj ⦄ ⦃ _ : Cartesian _⇨_ ⦄ ⦃ _ : L.Cartesian _⇨_ ⦄ where

  assocˡ∘assocʳ : assocˡ ∘ assocʳ {a = a}{b}{c} ≈ id
  assocˡ∘assocʳ =
    begin
      assocˡ ∘ assocʳ
    ≡⟨⟩
      (second exl ▵ exr ∘ exr) ∘ (exl ∘ exl ▵ first exr)
    ≈⟨ ▵∘ ⟩
      second exl ∘ (exl ∘ exl ▵ first exr) ▵ (exr ∘ exr) ∘ (exl ∘ exl ▵ first exr)
    -- ≈⟨ ▵≈ second∘▵ ∘-assocʳ ⟩
    --   (exl ∘ exl ▵ exl ∘ first exr) ▵ exr ∘ exr ∘ (exl ∘ exl ▵ first exr)
    -- ≈⟨ ▵≈ (▵≈ʳ exl∘⊗) (∘≈ʳ exr∘▵ ; exr∘first) ⟩
    -- -- The preceding commented group of lines is replaced by the following line.
    -- -- Likewise below. For faster compiles, but maybe not worth it.
    ≈⟨ ▵≈ (second∘▵ ; ▵≈ʳ exl∘⊗) (∘-assocʳ ; ∘≈ʳ exr∘▵ ; exr∘first) ⟩
      (exl ∘ exl ▵ exr ∘ exl) ▵ exr
    -- ≈⟨ ▵≈ˡ (sym ▵∘) ⟩
    --   (exl ▵ exr) ∘ exl ▵ exr
    -- ≈⟨ ▵≈ˡ (∘≈ˡ exl▵exr ; identityˡ) ⟩
    ≈⟨ ▵≈ˡ (sym ▵∘ ; ∘≈ˡ exl▵exr ; identityˡ) ⟩
      exl ▵ exr
    ≈⟨ exl▵exr ⟩
      id
    ∎

  assocʳ∘assocˡ : assocʳ ∘ assocˡ {a = a}{b}{c} ≈ id
  assocʳ∘assocˡ =
    begin
      assocʳ ∘ assocˡ
    ≡⟨⟩
      (exl ∘ exl ▵ first exr) ∘ (second exl ▵ exr ∘ exr)
    ≈⟨ ▵∘ ⟩
      (exl ∘ exl) ∘ (second exl ▵ exr ∘ exr) ▵ first exr ∘ (second exl ▵ exr ∘ exr)
    -- ≈⟨ ▵≈ ∘-assocʳ first∘▵ ⟩
    --   exl ∘ exl ∘ (second exl ▵ exr ∘ exr) ▵ (exr ∘ second exl ▵ exr ∘ exr)
    -- ≈⟨ ▵≈ (∘≈ʳ exl∘▵) (▵≈ˡ exr∘second) ⟩
    ≈⟨ ▵≈ (∘-assocʳ ; ∘≈ʳ exl∘▵) (first∘▵ ; ▵≈ˡ exr∘second) ⟩
      exl ∘ second exl ▵ (exl ∘ exr ▵ exr ∘ exr)
    ≈⟨ ▵≈ exl∘second (sym ▵∘) ⟩
      exl ▵ (exl ▵ exr) ∘ exr
    ≈⟨ ▵≈ʳ (∘≈ˡ exl▵exr ; identityˡ) ⟩
      exl ▵ exr
    ≈⟨ exl▵exr ⟩
      id
    ∎

  ⊗⊗∘assocʳ : ∀ {f : a ⇨ a′}{g : b ⇨ b′}{h : c ⇨ c′}
           → (f ⊗ (g ⊗ h)) ∘ assocʳ ≈ assocʳ ∘ ((f ⊗ g) ⊗ h)
  ⊗⊗∘assocʳ {f = f}{g}{h} =
    begin
      (f ⊗ (g ⊗ h)) ∘ assocʳ
    ≡⟨⟩
      (f ⊗ (g ⊗ h)) ∘ (exl ∘ exl ▵ first exr)
    ≈⟨ ⊗∘▵ ⟩
      f ∘ exl ∘ exl ▵ (g ⊗ h) ∘ first exr
    -- ≈⟨ ▵≈ʳ ⊗∘first ⟩
    --   f ∘ exl ∘ exl ▵ (g ∘ exr ⊗ h)
    -- ≈⟨ ▵≈ʳ (⊗≈ˡ (sym exr∘⊗)) ⟩
    --   f ∘ exl ∘ exl ▵ (exr ∘ (f ⊗ g) ⊗ h)
    -- ≈⟨ ▵≈ʳ (sym first∘⊗) ⟩
    ≈⟨ ▵≈ʳ (⊗∘first ; ⊗≈ˡ (sym exr∘⊗) ; sym first∘⊗) ⟩
      f ∘ exl ∘ exl ▵ first exr ∘ ((f ⊗ g) ⊗ h)
    -- ≈⟨ ▵≈ˡ (∘-assocˡʳ′ (sym exl∘⊗)) ⟩
    --   exl ∘ (f ⊗ g) ∘ exl ▵ first exr ∘ ((f ⊗ g) ⊗ h)
    -- ≈⟨ ▵≈ˡ (∘≈ʳ (sym exl∘⊗)) ⟩
    --   exl ∘ exl ∘ ((f ⊗ g) ⊗ h) ▵ first exr ∘ ((f ⊗ g) ⊗ h)
    -- ≈⟨ ▵≈ˡ ∘-assocˡ ⟩
    ≈⟨ ▵≈ˡ (∘-assocˡʳ′ (sym exl∘⊗) ; ∘≈ʳ (sym exl∘⊗) ; ∘-assocˡ) ⟩
      (exl ∘ exl) ∘ ((f ⊗ g) ⊗ h) ▵ first exr ∘ ((f ⊗ g) ⊗ h)
    ≈⟨ sym ▵∘ ⟩
      (exl ∘ exl ▵ first exr) ∘ ((f ⊗ g) ⊗ h)
    ≡⟨⟩
      assocʳ ∘ ((f ⊗ g) ⊗ h)
    ∎

  -- TODO:
  ⊗⊗∘assocˡ : ∀ {f : a ⇨ a′}{g : b ⇨ b′}{h : c ⇨ c′}
           → ((f ⊗ g) ⊗ h) ∘ assocˡ ≈ assocˡ ∘ (f ⊗ (g ⊗ h))
  ⊗⊗∘assocˡ {f = f}{g}{h} =
    begin
      ((f ⊗ g) ⊗ h) ∘ assocˡ
    ≡⟨⟩
      ((f ⊗ g) ⊗ h) ∘ (second exl ▵ exr ∘ exr)
    ≈⟨ ⊗∘▵ ⟩
      (f ⊗ g) ∘ second exl ▵ h ∘ exr ∘ exr
    -- ≈⟨ ▵≈ˡ ⊗∘second ⟩
    --   (f ⊗ g ∘ exl) ▵ h ∘ exr ∘ exr
    -- ≈⟨ ▵≈ˡ (⊗≈ʳ (sym exl∘⊗)) ⟩
    ≈⟨ ▵≈ˡ (⊗∘second ; ⊗≈ʳ (sym exl∘⊗)) ⟩
      (f ⊗ exl ∘ (g ⊗ h)) ▵ h ∘ exr ∘ exr
    -- ≈⟨ ▵≈ʳ (∘-assocˡʳ′ (sym exr∘⊗)) ⟩
    --   (f ⊗ exl ∘ (g ⊗ h)) ▵ exr ∘ (g ⊗ h) ∘ exr
    -- ≈⟨ ▵≈ʳ (∘≈ʳ (sym exr∘⊗)) ⟩
    ≈⟨ ▵≈ʳ (∘-assocˡʳ′ (sym exr∘⊗) ; ∘≈ʳ (sym exr∘⊗)) ⟩
      (f ⊗ exl ∘ (g ⊗ h)) ▵ exr ∘ exr ∘ (f ⊗ (g ⊗ h))
    ≈⟨ ▵≈ (sym second∘⊗) ∘-assocˡ ⟩
      second exl ∘ (f ⊗ (g ⊗ h)) ▵ (exr ∘ exr) ∘ (f ⊗ (g ⊗ h))
    ≈⟨ sym ▵∘ ⟩
      (second exl ▵ exr ∘ exr) ∘ (f ⊗ (g ⊗ h))
    ≡⟨⟩
      assocˡ ∘ (f ⊗ (g ⊗ h))
    ∎

  first-first∘assocˡ : ∀ {b c : obj}{f : a ⇨ d}
    → first {b = c} (first {b = b} f) ∘ assocˡ ≈ assocˡ ∘ first f
  first-first∘assocˡ = ⊗⊗∘assocˡ ; ∘≈ʳ (⊗≈ʳ id⊗id)

  -- first-first∘assocˡ {f = f} =
  --   begin
  --     first (first f) ∘ assocˡ
  --   ≡⟨⟩
  --     ((f ⊗ id) ⊗ id) ∘ assocˡ
  --   ≈⟨ ⊗⊗∘assocˡ ⟩
  --     assocˡ ∘ (f ⊗ (id ⊗ id))
  --   ≈⟨ ∘≈ʳ (⊗≈ʳ id⊗id) ⟩
  --     assocˡ ∘ (f ⊗ id)
  --   ≡⟨⟩
  --     assocˡ ∘ first f
  --   ∎

  first-first : ∀ {b c : obj}{f : a ⇨ d}
    → first {b = c} (first {b = b} f) ≈ assocˡ ∘ first f ∘ assocʳ -- inAssocʳ f
  first-first {f = f} =
    begin
      first (first f)
    ≈⟨ introʳ assocˡ∘assocʳ ⟩
      first (first f) ∘ assocˡ ∘ assocʳ
    ≈⟨ ∘-assocˡʳ′ first-first∘assocˡ ⟩
      assocˡ ∘ first f ∘ assocʳ
    ∎

open Assoc public
