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
        then roses 
    else nil))))
    )

; Have at least two weights to add up
; argument c is a wildcard parameter
; (deffunction get-total-rules-weight (?a ?b $?c)
;     (bind ?response (ask-question ?question 1 2 3 4))
;     (if (eq ?response 1)
;         then cabbage 
;     else (if (eq ?response 2)
;         then banana
;     else (if (eq ?response 3)
;         then maize 
;     else (if (eq ?response 4)
;         then roses 
;     else nil))))
;     )

;;;; Query Rules ;;;;
;____________________;


(defrule determine-plant "Rules for when no plant name or diagnosis is available"
    (not (plant-name ?))
    (not (disease ?))
    =>
    (assert (plant-name (which-plant "Which type of plant has a problem?  (1.cabbage 2.banana 3.maize 4.roses)? "))))

;;;; Query Plant Conditions ;;;;

(defrule determine-yellow-patch-leaves ""
   (plant-name rose)
   =>
   (assert (has-yellow-patch-leaves (yes-or-no-p "Does the plant have yellow patches on its leaves? (yes/no)? "))))

(defrule determine-orange-spores-leaves ""
   (plant-name rose)
   =>
   (assert (has-orange-spores-leaves (yes-or-no-p "Does the plant have Orange pustules of spores underneath the leaves? (yes/no)? "))))

(defrule determine-leaves-fall ""
   (plant-name rose)
   =>
   (assert (has-leaves-fall (yes-or-no-p "Do the affected leaves fall prior to healthy ones? (yes/no)? "))))

(defrule determine-plants-defoliated ""
   (plant-name rose)
   =>
   (assert (has-leaves-defoliated (yes-or-no-p "Do the plants defoliated in serious infections? (yes/no)? "))))
   
(defrule determine-black-spots-leaves ""
   (plant-name rose)
   =>
   (assert (has-black-spots-leaves (yes-or-no-p "Does the plant have black spots on its leaves? (yes/no)? "))))
   
(defrule determine-distance-between-spots ""
   (plant-name rose)
   =>
   (assert (has-distance-between-spots (yes-or-no-p "Are the spots as far as 12mm apart? (yes/no)? "))))
   
(defrule determine-circular-spots-irregular-edge-yellow-halo ""
   (plant-name rose)
   =>
   (assert (has-circular-spots-irregular-edge-yellow-halo (yes-or-no-p "Does the plant have circular spots with an irregular edge with a yellow halo? (yes/no)? "))))

(defrule determine-yellow-leaves-fall-early ""
   (plant-name rose)
   =>
   (assert (has-yellow-leaves-fall-early (yes-or-no-p "Do the plants' leaves turn yellow and fall early? (yes/no)? "))))
   
(defrule determine-continual-defoliation-cause-death ""
   (plant-name rose)
   =>
   (assert (has-continual-defoliation-cause-death (yes-or-no-p "Does the plant have continual defoliation that causes weakness, dieback or death of the plant? (yes/no)? "))))

(defrule determine-chewed-holes-of-irregular-shapes ""
   (plant-name rose)
   =>
   (assert (has-chewed-holes-of-irregular-shapes (yes-or-no-p "Does the plant have chewed holes of irregular shapes in young leaves and buds? (yes/no)? "))))

(defrule determine-leaves-holes-enlarge ""
   (plant-name rose)
   =>
   (assert (has-leaves-holes-enlarge (yes-or-no-p "Do the leaves and holes enlarge? (yes/no)? "))))
   
(defrule determine-silvering-of-leaves ""
   (plant-name rose)
   =>
   (assert (has-silvering-of-leaves (yes-or-no-p "Do the plants' leaves silver? (yes/no)? "))))
   
(defrule determine-fine-webbing-eggs-underside ""
   (plant-name rose)
   =>
   (assert (has-fine-webbing-eggs-underside (yes-or-no-p "Do the plants have fine webbing and eggs on the undersides of the leaves? (yes/no)? "))))
   
(defrule determine-irregular-yellow-patches-leaves ""
   (plant-name cabbage)
   =>
   (assert (has-irregular-yellow-patches-leaves (yes-or-no-p "Does the plant have irregular yellow patches on its leaves? (yes/no)? "))))

(defrule determine-fluffy-gray-growth-leaves ""
   (plant-name cabbage)
   =>
   (assert (has-fluffy-gray-growth-leaves (yes-or-no-p "Does the plant have fluffy gray growth on underside of leaves? (yes/no)? "))))

(defrule determine-white-pustules ""
   (plant-name cabbage)
   =>
   (assert (has-white-pustules (yes-or-no-p "Does the plant have white pustules on leaves, stems or flowers? (yes/no)? "))))

(defrule determine-leaves-roll-thicken ""
   (plant-name cabbage)
   =>
   (assert (has-leaves-roll-thicken (yes-or-no-p "Have the plant leaves rolled and thickened? (yes/no)? "))))

(defrule determine-irregularly-shaped-holes-leaves-stems ""
   (plant-name cabbage)
   =>
   (assert (has-irregularly-shaped-holes-leaves-stems (yes-or-no-p "Do the plants have irregularly shaped holes in leaves and stems? (yes/no)? "))))

   (defrule determine-slime-trails ""
   (plant-name cabbage)
   =>
   (assert (has-slime-trails (yes-or-no-p "Are there slime trails present on the plant and surrounding soil? (yes/no)? "))))

   (defrule determine-shredded-leaves ""
   (plant-name cabbage)
   =>
   (assert (has-shredded-leaves (yes-or-no-p "Do the plants possess shredded leaves? (yes/no)? "))))

   (defrule determine-ragged-holes ""
   (plant-name cabbage)
   =>
   (assert (has-ragged-holes (yes-or-no-p "Do the plants have ragged holes in leaves bored into head? (yes/no)? "))))

   (defrule determine-frass ""
   (plant-name cabbage)
   =>
   (assert (has-frass (yes-or-no-p "Do the plants have green-brown faeces(frass) on leaves? (yes/no)? "))))

   (defrule determine-caterpillar-green-hairy""
   (plant-name cabbage)
   =>
   (assert (has-caterpillar-green-hairy (yes-or-no-p "Presence of a caterpillar that is green and hairy? (yes/no)? "))))


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
