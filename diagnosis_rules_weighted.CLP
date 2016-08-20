;;;; Symptom Details Template ;;;;

(deftemplate symptom-details
    (slot symptom-name)
    (slot plant-name)
    (slot disease-or-pest)
    (slot prescence (default no))
    (slot weight (default 0)))

(deftemplate disease-weight
    (slot disease-or-pest-name )
    (slot plant-name )
    (slot weight (default 0)))

; Deffunctions 

(deffunction ask-question (?question $?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer) 
       then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer) 
          then (bind ?answer (lowcase ?answer))))
   ?answer)

(deffunction yes-or-no-p (?question)
   (bind ?response (ask-question ?question yes no y n))
   (if (or (eq ?response yes) (eq ?response y))
        then yes 
    else no))

(deffunction which-plant (?question)
    (bind ?response (ask-question ?question 1 2 3 4))
    (if (eq ?response 1)
        then cabbage 
    else (if (eq ?response 2)
        then banana
    else (if (eq ?response 3)
        then maize 
    else (if (eq ?response 4)
        then rose 
    else nil))))
    )

; Get Weight Totals and Give Diagnosis based on Threshold
(deffunction diagnose-plant (?plant-name ?disease-or-pest ?threshold)
    (bind ?weight 0)
    (do-for-all-facts ((?g symptom-details)) 
        (and 
            (eq ?g:prescence yes)
            (eq ?g:plant-name ?plant-name)
            (eq ?g:disease-or-pest ?disease-or-pest))
        (bind ?weight (+ ?weight ?g:weight)))
        (assert (disease-weight (disease-or-pest-name ?disease-or-pest)
                                (plant-name ?plant-name)
                                (weight ?weight)))
    (if (> ?weight ?threshold)
        then TRUE))


;;;; Query Rules ;;;;
;____________________;


(defrule determine-plant "Rules for when no plant name or diagnosis is available"
    (not (diagnosis ?))
    (not (plant-name ?))
    =>
    (assert (plant-name (which-plant "Which type of plant has a problem?  (1.cabbage 2.banana 3.maize 4.rose)? "))))

;;;; Query Plant Conditions ;;;;

;;; Roses Symtpoms ;;;
;;; -------------- ;;;
;;; Disease 1: Rose Rust ;;;
(defrule determine-yellow-patch-leaves ""
   (not (diagnosis ?))
   (plant-name rose)
   =>
    (assert
        (symptom-details 
            (symptom-name yellow-patch-leaves)
            (plant-name rose)
            (disease-or-pest rose-rust)
            (prescence 
                (yes-or-no-p "Does the plant have yellow patches on its leaves? (yes/no)? "))
            (weight 25))))

(defrule determine-orange-spores-leaves ""
   (not (diagnosis ?))
   (plant-name rose)
   =>
   (assert
        (symptom-details 
            (symptom-name orange-spores-leaves)
            (plant-name rose)
            (disease-or-pest rose-rust)
            (prescence 
                (yes-or-no-p "Does the plant have Orange pustules of spores underneath the leaves? (yes/no)? "))
            (weight 25))))
   
(defrule determine-leaves-fall ""
   (not (diagnosis ?))
   (plant-name rose)
   =>
   (assert
        (symptom-details 
            (symptom-name leaves-fall)
            (plant-name rose)
            (disease-or-pest rose-rust)
            (prescence 
                (yes-or-no-p "Do the affected leaves fall prior to healthy ones? (yes/no)? "))
            (weight 25))))

(defrule determine-plants-defoliated ""
   (not (diagnosis ?))
   (plant-name rose)
   =>
   (assert
        (symptom-details 
            (symptom-name plants-defoliated)
            (plant-name rose)
            (disease-or-pest rose-rust)
            (prescence 
                (yes-or-no-p "Are the plants defoliated in serious infections? (yes/no)? "))
            (weight 25))
        (check-rose-rust-diagnosis)))
   
;;; Disease 2: Black Spot ;;;
(defrule determine-black-spots-leaves ""
   (not (diagnosis ?))
   (plant-name rose)
   =>
   (assert
        (symptom-details 
            (symptom-name black-spots-leaves)
            (plant-name rose)
            (disease-or-pest black-spot)
            (prescence 
                (yes-or-no-p "Does the plant have black spots on its leaves? (yes/no)? "))
            (weight 20))))
   
(defrule determine-distance-between-spots ""
   (not (diagnosis ?))
   (plant-name rose)
   =>
   (assert
        (symptom-details 
            (symptom-name distance-between-spots)
            (plant-name rose)
            (disease-or-pest black-spot)
            (prescence 
                (yes-or-no-p "Are the spots as far as 12mm apart? (yes/no)? "))
            (weight 20))))
   
(defrule determine-circular-spots-irregular-edge-yellow-halo ""
   (not (diagnosis ?))
   (plant-name rose)
   =>
   (assert
        (symptom-details 
            (symptom-name circular-spots-irregular-edge-yellow-halo)
            (plant-name rose)
            (disease-or-pest black-spot)
            (prescence 
                (yes-or-no-p "Does the plant have circular spots with an irregular edge with a yellow halo? (yes/no)? "))
            (weight 20))))

(defrule determine-yellow-leaves-fall-early ""
   (not (diagnosis ?))
   (plant-name rose)
   =>
   (assert
        (symptom-details 
            (symptom-name yellow-leaves-fall-early)
            (plant-name rose)
            (disease-or-pest black-spot)
            (prescence 
                (yes-or-no-p "Do the plants' leaves turn yellow and fall early? (yes/no)? "))
            (weight 20))))
   
(defrule determine-continual-defoliation-cause-death ""
   (not (diagnosis ?))
   (plant-name rose)
   =>
    (assert
        (symptom-details 
            (symptom-name continual-defoliation-cause-death)
            (plant-name rose)
            (disease-or-pest black-spot)
            (prescence 
                (yes-or-no-p "Does the plant have continual defoliation that causes weakness, dieback or death of the plant? (yes/no)? "))
            (weight 20))
        (check-black-spot-diagnosis)))

; ;;; Pest 1: Metallic Flea Beetles ;;;
; (defrule determine-chewed-holes-of-irregular-shapes ""
;    (not (diagnosis ?))
;    (plant-name rose)
;    =>
;    (assert (has-chewed-holes-of-irregular-shapes (yes-or-no-p "Does the plant have chewed holes of irregular shapes in young leaves and buds? (yes/no)? "))))

; (defrule determine-leaves-holes-enlarge ""
;    (not (diagnosis ?))
;    (plant-name rose)
;    =>
;    (assert (has-leaves-holes-enlarge (yes-or-no-p "Do the leaves and holes enlarge? (yes/no)? "))))
   
; ;;; Pest 2: Two-spotted mite, Spider Mite or Red Spider Mite ;;;
; (defrule determine-silvering-of-leaves ""
;    (not (diagnosis ?))
;    (plant-name rose)
;    =>
;    (assert (has-silvering-of-leaves (yes-or-no-p "Do the plants' leaves silver? (yes/no)? "))))
   
; (defrule determine-fine-webbing-eggs-underside ""
;    (not (diagnosis ?))
;    (plant-name rose)
;    =>
;    (assert (has-fine-webbing-eggs-underside (yes-or-no-p "Do the plants have fine webbing and eggs on the undersides of the leaves? (yes/no)? "))))


; ;;; Banana Symtpoms ;;;
; ;;; --------------- ;;;
; ;;; Disease 1: Rhizome Rot ;;;
; (defrule determine-yellow-brown-watery-internal-tissue ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-yellow-brown-watery-internal-tissue (yes-or-no-p "Is the internal tissue yellow/brown and watery? (yes/no)? "))))
   
; (defrule determine-pseudostem-breaks-from-rhizome ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-pseudostem-breaks-from-rhizome (yes-or-no-p "Does the pseudostem break from the rhizome? (yes/no)? "))))
   
; (defrule determine-rhizome-fails-to-germinate ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-rhizome-fails-to-germinate (yes-or-no-p "Does the rhizome fail to germinate (does not form new leaves)? (yes/no)? "))))
   
; ;;; Disease 2: Banana Mosaic ;;;
; (defrule determine-chlorotic-mottling-stripes-on-foliage ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-chlorotic-mottling-stripes-on-foliage (yes-or-no-p "Is there chlorotic mottling or stripes on foliage? (yes/no)? "))))
   
; (defrule determine-distorted-fruit-with-chlorotic-streaks-mottling ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-distorted-fruit-with-chlorotic-streaks-mottling (yes-or-no-p "Does the plant have distorted fruit which may have chlorotic streaks or mottling? (yes/no)? "))))
   
; (defrule determine-distorted-leaves ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-distorted-leaves (yes-or-no-p "Does the plant have distorted leaves? (yes/no)? "))))
   
; (defrule determine-leaf-necrosis ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-leaf-necrosis (yes-or-no-p "Do the leaves have black, brown or tan spots, holes or discolourations? (yes/no)? "))))
  
; ;;; Pest 1: Banana Aphid ;;; 
; (defrule determine-deformed-plants-curled-shrivelled-leaves ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-deformed-plants-curled-shrivelled-leaves (yes-or-no-p "Are the plants deformed with curled, shrivelled leaves? (yes/no)? "))))
   
; (defrule determine-galls-form-on-leaves ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-galls-form-on-leaves (yes-or-no-p "Do galls form on the leaves of the plant? (yes/no)? "))))
   
; (defrule determine-colonies-of-aphids-present ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-colonies-of-aphids-present (yes-or-no-p "Are colonies of aphids present in the crown of the plant at the base of pseudostem or between the outer leaf sheaths? (yes/no)? "))))

; ;;; Pest 2: Banana Weevil ;;; 
; (defrule determine-visible-tunnels-in-corm ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-visible-tunnels-in-corm (yes-or-no-p "Do the plants have visible tunnels in corm as rounded holes up to 8 mm in diameter? (yes/no)? "))))
   
; (defrule determine-plants-wilting-toppling ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-plants-wilting-toppling (yes-or-no-p "Do the plants wilt and topple over? (yes/no)? "))))

; (defrule determine-destruction-root-system ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-destruction-root-system (yes-or-no-p "Do the plants face destruction of the root system? (yes/no)? "))))
   
; (defrule determine-reduced-plant-growth ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-reduced-plant-growth (yes-or-no-p "Do the plants have reduced growth? (yes/no)? "))))
   
; (defrule determine-reduced-fruit-production ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-reduced-fruit-production (yes-or-no-p "Do the plants have reduced fruit production? (yes/no)? "))))
   
; (defrule determine-black-beetle-between-leaf-sheaths ""
;    (not (diagnosis ?))
;    (plant-name banana)
;    =>
;    (assert (has-black-beetle-between-leaf-sheaths (yes-or-no-p "Are there black hard-shelled beetles between leaf sheaths? (yes/no)? "))))
   
; ;;; Cabbage Symtpoms ;;;
; ;;; ---------------- ;;;
; ;;; Disease 1: Downy Mildew ;;; 

; (defrule determine-irregular-yellow-patches-leaves ""
;    (not (diagnosis ?))
;    (plant-name cabbage)
;    =>
;    (assert (has-irregular-yellow-patches-leaves (yes-or-no-p "Does the plant have irregular yellow patches on its leaves? (yes/no)? "))))

; (defrule determine-fluffy-gray-growth-leaves ""
;    (not (diagnosis ?))
;    (plant-name cabbage)
;    =>
;    (assert (has-fluffy-gray-growth-leaves (yes-or-no-p "Does the plant have fluffy gray growth on underside of leaves? (yes/no)? "))))

; ;;; Disease 2: White Rust ;;; 
; (defrule determine-white-pustules ""
;    (not (diagnosis ?))
;    (plant-name cabbage)
;    =>
;    (assert (has-white-pustules (yes-or-no-p "Does the plant have white pustules on leaves, stems or flowers? (yes/no)? "))))

; (defrule determine-leaves-roll-thicken ""
;    (not (diagnosis ?))
;    (plant-name cabbage)
;    =>
;    (assert (has-leaves-roll-thicken (yes-or-no-p "Have the plant leaves rolled and thickened? (yes/no)? "))))

; ;;; Pest 1: Slugs and Snails ;;; 
; (defrule determine-irregularly-shaped-holes-leaves-stems ""
;    (not (diagnosis ?))
;    (plant-name cabbage)
;    =>
;    (assert (has-irregularly-shaped-holes-leaves-stems (yes-or-no-p "Do the plants have irregularly shaped holes in leaves and stems? (yes/no)? "))))

;    (defrule determine-slime-trails ""
;    (not (diagnosis ?))
;    (plant-name cabbage)
;    =>
;    (assert (has-slime-trails (yes-or-no-p "Are there slime trails present on the plant and surrounding soil? (yes/no)? "))))

;    (defrule determine-shredded-leaves ""
;    (not (diagnosis ?))
;    (plant-name cabbage)
;    =>
;    (assert (has-shredded-leaves (yes-or-no-p "Do the plants possess shredded leaves? (yes/no)? "))))

; ;;; Pest 2: Cabbageworm ;;; 
;    (defrule determine-ragged-holes ""
;    (not (diagnosis ?))
;    (plant-name cabbage)
;    =>
;    (assert (has-ragged-holes (yes-or-no-p "Do the plants have ragged holes in leaves bored into head? (yes/no)? "))))

;    (defrule determine-frass ""
;    (not (diagnosis ?))
;    (plant-name cabbage)
;    =>
;    (assert (has-frass (yes-or-no-p "Do the plants have green-brown faeces(frass) on leaves? (yes/no)? "))))

;    (defrule determine-caterpillar-green-hairy""
;    (not (diagnosis ?))
;    (plant-name cabbage)
;    =>
;    (assert (has-caterpillar-green-hairy (yes-or-no-p "Presence of a caterpillar that is green and hairy? (yes/no)? "))))

; ;;; Maize Symtpoms ;;;
; ;;; -------------- ;;;
; ;;; Desease 1: Gibrella Ear Rot ;;;
;    (defrule determine-red-pink-mold""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-red-pink-mold (yes-or-no-p "Is there red or pink coloured mold on ear tip? (yes/no)? "))))

;    (defrule determine-husk-adhering-to-ear""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-husk-adhering-to-ear(yes-or-no-p "Does the husk adhere tightly to the ear? (yes/no)? "))))

;    (defrule determine-white-mycelium""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-white-mycelium(yes-or-no-p "Presence of white mold gradually moving towards base of the ear? (yes/no)? "))))

;    (defrule determine-extensive-kernel-rotting""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-extensive-kernel-rotting(yes-or-no-p "Can you observe extensive kernel rotting? (yes/no)? "))))

;    (defrule determine-bluish-black-perithecia-on-husks""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-bluish-black-perithecia-on-husks(yes-or-no-p "Do the husks have bluish-black perithecia? (yes/no)? "))))

; ;;; Disease 2: Leaf Blight ;;; 
;    (defrule determine-gray-green-lesions-leaves""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-gray-green-lesions-leaves(yes-or-no-p "Do the leaves have elliptical necrotic gray-green lesions? (yes/no)? "))))

;    (defrule determine-spore-formation-leaves""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-spore-formation-leaves(yes-or-no-p "Is there spore formation on leaves? (yes/no)? "))))

;    (defrule determine-dead-tissue""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-dead-tissue(yes-or-no-p "Are there large areas of dead tissue? (yes/no)? "))))

; ;;; Pest 1: Termites ;;;
;    (defrule determine-defoliation-seedlings""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-defoliation-seedlings(yes-or-no-p "Is there partial or total defoliation of seedlings (yes/no)? "))))

;    (defrule determine-withering""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-withering(yes-or-no-p "Presence of withering? (yes/no)? "))))

;    (defrule determine-plant-lodging""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-plant-lodging(yes-or-no-p "Is the alignment of the root or stem vertically displaced? (yes/no)? "))))

;    (defrule determine-plant-death""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-plant-death(yes-or-no-p "Are the plants dying? (yes/no)? "))))

; ;;; Pest 2: weevils ;;;
;    (defrule determine-holes-on-grains""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-holes-on-grains(yes-or-no-p "Are there circular or ragged holes on the surface of the grains? (yes/no)? "))))

;    (defrule determine-grains-float""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-grains-float(yes-or-no-p "Do the grains float if placed on water? (yes/no)? "))))

;    (defrule determine-grain-dust""
;    (not (diagnosis ?))
;    (plant-name maize)
;    =>
;    (assert (has-grain-dust(yes-or-no-p "Presence of flour-like grain dust mixed with frass? (yes/no)? "))))


;;;; DIAGNOSES ;;;;
(defrule confirm-rose-rust
   ?f <- (check-rose-rust-diagnosis)
   =>
   (retract ?f)
   (if (diagnose-plant rose rose-rust 70)
      then
      (assert (diagnosis "Your Roses seem to be Suffering from Rose Rust"))))


(defrule confirm-black-spot
    ?f <- (check-black-spot-diagnosis)
    =>
    (retract ?f)
    (if (diagnose-plant rose black-spot 70)
        then
        (assert (diagnosis "Your Roses seem to be Suffering from Black Spot")))
    (assert (check-most-probable)))

(defrule find-most-probable-disease
    (not (diagnosis ?))
    ?f <- (check-most-probable)
    (disease-weight (disease-or-pest-name ?disease-or-pest-name1)
                    (plant-name ?plant-name)
                    (weight ?weight1))
   (not (disease-weight (weight ?weight2&:(> ?weight2 ?weight1))))
   =>
   ; (retract ?f)
   (printout t crlf crlf "--------------------------------------------------------------------" crlf
                "We don't have sufficient information on the condition of your plant." crlf
    "But your " ?plant-name " most likey suffers from " ?disease-or-pest-name1 crlf))


;;;; Add Advice here, maybe? ;;;;

; Startup n Conclusion Rules

(defrule system-banner ""
    (declare (salience 10))
    =>
    (printout t crlf crlf)
    (printout t "Horticulture Diagnosis Expert System")
    (printout t crlf crlf))

(defrule print-diagnosis ""
    (declare (salience 10))
    (diagnosis ?item)
    =>
    (printout t crlf crlf)
    (printout t "Diagnosis:")
    (printout t crlf crlf)
    (format t " %s%n%n" ?item))
