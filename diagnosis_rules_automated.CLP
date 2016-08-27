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

; Dynamically generate query rules ;

(deffunction create-query-rules (?template
                                ?plant-name
                                ?disease-or-pest
                                ?symptom
                                ?qn
                                ?weight)
    (bind ?symptom-rule-name (str-cat "determine-" ?symptom))
    (build (str-cat
            "(defrule " ?symptom-rule-name
                "(not (diagnosis ?))
                 (plant-name " ?plant-name ")
                =>
                (assert
                    (" ?template 
                        "(symptom-name " ?symptom ")
                        (plant-name " ?plant-name ")
                        (disease-or-pest " ?disease-or-pest ")
                        (prescence 
                            (yes-or-no-p " ?qn "))
                        (weight " ?weight ")))

             )"
          ) 
    )
)

; Dynamically generate rules to check for diagnosis;
(deffunction create-check-diagnosis-rule (
                                ?plant-name
                                ?disease-or-pest)
    (bind ?symptom-rule-name (str-cat "check-" ?disease-or-pest "-diagnosis"))
    (build (str-cat
            "(defrule " ?symptom-rule-name
                "(not (diagnosis ?))
                 (plant-name " ?plant-name ")
                =>
                (assert
                    (" ?symptom-rule-name ")))"
            )) 
)

(deffunction read-from-file (?template ?file)
    (open ?file file-data)
    (bind ?stop FALSE)
    (bind ?plant-name (read file-data))
    (bind ?disease-or-pest (read file-data))
    ; (read file-data) ;avoid readlining empty end of line
    (while (not ?stop)
        (bind ?temp-line (readline file-data))
        (if (eq ?temp-line EOF)
            then (bind ?stop TRUE)
        else (if (eq ?temp-line "ENDGROUP")

            then (printout t "next please!" crlf)
            (create-check-diagnosis-rule ?plant-name ?disease-or-pest)
            (bind ?plant-name (read file-data))
            (bind ?disease-or-pest (read file-data))
            ; (read file-data) ;avoid readlining empty end of line
        else (if (eq ?temp-line "")
                then (printout t "empty") ;do nothing
        else
            (bind ?exp-line (explode$ ?temp-line))
            (create-query-rules
                ?template 
                ?plant-name
                ?disease-or-pest
                (implode$ (subseq$ ?exp-line 1 1))
                (implode$ (subseq$ ?exp-line 2 2)) ;prevent double string
                (implode$ (subseq$ ?exp-line 3 3)))
            ))))
    (close))

; Call the read-from-file function to generate the rules

(defrule start-program
   (declare (salience 1))
   =>
   (read-from-file symptom-details symptoms.txt))


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
