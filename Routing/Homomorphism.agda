{-# OPTIONS --safe --without-K #-}

open import Level
open import Function using (id) renaming (_∘_ to _∙_)
open import Data.Unit
open import Data.Product using (_,_)
open import Relation.Binary.PropositionalEquality
  renaming (refl to ≡-refl; sym to ≡-sym; trans to ≡-trans)

module Routing.Homomorphism where

open import Functions.Raw
open import Routing.Raw public
open import Ty
open import Index

open import Categorical.Homomorphism hiding (id)
open import Categorical.Laws

lookup∘tabulate : ∀{a}{f : Indexer Fₒ a} → ∀{z}(i : Index z a)
                → lookup {a = a} (tabulate {a = a} f) i ≡ f i
lookup∘tabulate bit       = ≡-refl
lookup∘tabulate fun       = ≡-refl
lookup∘tabulate (left i)  = lookup∘tabulate i
lookup∘tabulate (right i) = lookup∘tabulate i

≈-tabulate : (a : Ty){f g : Indexer Fₒ a} → (∀{z}(i : Index z a) → f i ≡ g i)
           → tabulate f ≡ tabulate g
≈-tabulate `⊤ hip        =  ≡-refl
≈-tabulate `Bool hip     = hip bit
≈-tabulate (a `⇛ a₁) hip = hip fun
≈-tabulate (a `× a₁) hip = cong₂ _,_ (≈-tabulate a (hip ∙ left))
                                     (≈-tabulate a₁ (hip ∙ right))

lookup-swizzle-∘ : {b c a : Ty}{g : Swizzle b c}{f : Swizzle a b}{x : Fₒ a}
                 → ∀{z}(i : Index z c)
                 → lookup (swizzle f x) (g i) ≡ lookup (tabulate (lookup x ∘ f ∘ g)) i
lookup-swizzle-∘ {g = g} i = ≡-trans (lookup∘tabulate (g i)) (≡-sym (lookup∘tabulate i))

swizzle-id : (a : Ty) → swizzle {a = a} id ≈ id
swizzle-id `⊤         = ≡-refl
swizzle-id `Bool      = ≡-refl
swizzle-id (a₁ `⇛ a₂) = ≡-refl
swizzle-id (a₁ `× a₂) {(x₁ , x₂)} = cong₂ _,_ (swizzle-id a₁ {x₁}) (swizzle-id a₂ {x₂})

swizzle-∘ : {b c a : Ty}{g : Swizzle b c}{f : Swizzle a b}
          → swizzle (f ∘ g) ≈ swizzle g ∘ swizzle f
swizzle-∘ {b} {c} {a} {g} {f} {x} =
  begin
    swizzle (f ∘ g) x
  ≡⟨⟩
    tabulate ((lookup x ∘ f) ∘ g)
  ≡˘⟨ ≈-tabulate c (λ i → ≡-trans (lookup-swizzle-∘ {g = g} {f} i)
                                  (lookup∘tabulate i)) ⟩
    tabulate (lookup (tabulate (lookup x ∘ f)) ∘ g)
  ≡⟨⟩
    (swizzle g ∘ swizzle f) x
  ∎
 where open ≡-Reasoning

instance

  categoryH : CategoryH _⇨_ Function 0ℓ ⦃ Hₒ = ty-instances.homomorphismₒ ⦄
  categoryH = record
    { F-id = λ {a} → swizzle-id a
    ; F-∘ = λ {b} {c} {a} {g} {f} → swizzle-∘ {b} {c} {a} {unMk g} {unMk f}
    }

{-

-- TODO:

-- Also CartesianH, CartesianClosedH, and LogicH

-}
