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

(defglobal ?*analysis* = NIL)
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

(deffunction analysis-mode (?response)
   (if (or (eq ?response yes) (eq ?response y))
        then (bind ?*analysis* TRUE) 
    else (bind ?*analysis* FALSE) ))


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

; Get confidence level and Give Diagnosis based on Threshold
(deffunction diagnose-plant (?plant-name ?disease-or-pest ?threshold)
    (bind ?weight 1)
    (if ?*analysis*
        then
        (printout t "" crlf 
                    "Calculating total confidence level for "
                    ?disease-or-pest "..." crlf))
    (do-for-all-facts ((?g symptom-details)) 
        (and 
            (eq ?g:prescence yes)
            (eq ?g:plant-name ?plant-name)
            (eq ?g:disease-or-pest ?disease-or-pest))
        (if ?*analysis*
            then
            (printout t ?g:symptom-name " confidence level: " ?g:weight crlf)
            (printout t "Calculation: " ?weight " * (1 - "  ?g:weight ")" crlf))
        (bind ?weight (* ?weight (- 1 ?g:weight)))
        (if ?*analysis*
            then
            (printout t "= " ?weight crlf "" crlf)))
    (if ?*analysis*
        then
        (printout t "--------------------------------------------------" crlf
        "Total confidence level for " ?disease-or-pest " (1 - " ?weight ")"crlf))
    (bind ?weight (- 1 ?weight))
    (if ?*analysis*
        then
        (printout t "= " ?weight crlf 
        "And Threshold" crlf "= "?threshold crlf
        "--------------------------------------------------" crlf "" crlf))
    (assert (disease-weight (disease-or-pest-name ?disease-or-pest)
                            (plant-name ?plant-name)
                            (weight ?weight)))
    (if (> ?weight ?threshold)
        then TRUE))


;;;; Query Rules ;;;;
;____________________;

(defrule determine-plant "Rules for when no plant name or diagnosis is available"
    (analysis)
    (not (diagnosis ?))
    (not (plant-name ?))
    =>
    (assert (plant-name (which-plant "Which type of plant has a problem?  (1.cabbage 2.banana 3.maize 4.rose)? "))))

;;;; Query Plant Conditions ;;;;

; Dynamically generate query rules ;

(deffunction create-query-rules (?template ?plant-name ?disease-or-pest ?symptom ?qn ?weight)
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
                        (weight " ?weight "))))"
            )))

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
            )))

; Dynamically generate diagnosis rules ;
; (create-diagnosis-rules rose rose-rust 0.7 "Your Plants Seem to be suffering from Rose Rustnessness")
(deffunction create-diagnosis-rules (?plant-name ?disease-or-pest ?threshold ?diagnosis-st)
    (bind ?diagnosis-rule-name (str-cat "confirm-" ?disease-or-pest))
    (bind ?diagnosis-fact-name (str-cat "check-" ?disease-or-pest "-diagnosis"))
    (build (str-cat
            "(defrule " ?diagnosis-rule-name
            " ?f <- (" ?diagnosis-fact-name ")
                =>
                (retract ?f)
                (if (diagnose-plant " ?plant-name " " ?disease-or-pest " " ?threshold ")
                    then
                    (assert (diagnosis " ?diagnosis-st "))))"
            )))

; (defrule confirm-rose-rust
;    ?f <- (check-rose-rust-diagnosis)
;    =>
;    (retract ?f)
;    (if (diagnose-plant rose rose-rust 0.7)
;       then
;       (assert (diagnosis "Your Roses seem to be Suffering from Rose Rust"))))


(deffunction read-from-symptoms-file (?template ?file)
    (open ?file file-data) ; open the file and store data in file-data
    (bind ?stop FALSE) ; initialize stop variable to FALSE
    (bind ?plant-name (read file-data)) ; 1st line of the beginning of a new pest or disease is the plant name
    (bind ?disease-or-pest (read file-data)) ; 2nd line of the beginning of a new pest or disease is the disease or pest name
    (while (not ?stop) ; while stop variable is not TRUE
        (bind ?temp-line (readline file-data)) ; read entire line from text file
        (if (eq ?temp-line EOF) ; if End of File
            then (bind ?stop TRUE) ; Set stop variable to TRUE
        else (if (eq ?temp-line "ENDGROUP") ; If "ENDOFGROUP" check for the diagnosis of the disease or pest
            then
            (create-check-diagnosis-rule ?plant-name ?disease-or-pest)
            (bind ?plant-name (read file-data)) ; Read plant name of next group of symptoms
            (bind ?disease-or-pest (read file-data)) ; Read disease or pest name of next group of symptoms
        else (if (eq ?temp-line "") ; If reads empty string, do nothing
                then (printout t "") ; Do nothing
        else
            (bind ?exp-line (explode$ ?temp-line)) ; delimit the line read using spaces
            (create-query-rules ;create the rules needed to query the user
                ?template 
                ?plant-name
                ?disease-or-pest
                (implode$ (subseq$ ?exp-line 1 1))
                (implode$ (subseq$ ?exp-line 2 2))
                (implode$ (subseq$ ?exp-line 3 3)))
            ))))
    (close)) ;close the file when done


(deffunction read-from-diagnoses-file (?file)
    (open ?file file-data) ; open the file and store data in file-data
    (bind ?stop FALSE) ; initialize stop variable to FALSE
    (bind ?plant-name (read file-data)) ; 1st line of the beginning of a set of diagnoses is the plant name
    (while (not ?stop) ; while stop variable is not TRUE
        (bind ?temp-line (readline file-data)) ; read entire line from text file
        (if (eq ?temp-line EOF) ; if End of File
            then (bind ?stop TRUE) ; Set stop variable to TRUE
        else (if (eq ?temp-line "ENDGROUP") ; If "ENDGROUP" check for the diagnosis of the disease or pest
            then
            (bind ?plant-name (read file-data)) ; Read plant name of next set of diagnoses
        else (if (eq ?temp-line "") ; If reads empty string, do nothing
                then (printout t "") ; Do nothing
        else
            (bind ?exp-line (explode$ ?temp-line)) ; delimit the line read using spaces
            (create-diagnosis-rules ;create the rules needed to diagnose the plant
                ?plant-name
                (implode$ (subseq$ ?exp-line 1 1))
                (implode$ (subseq$ ?exp-line 2 2))
                (implode$ (subseq$ ?exp-line 3 3)))
            ))))
    (close)) ;close the file when done

; Call the read-from-symptoms-file and read-from-diagnoses-file functions to generate the rules
(defrule start-program
   (declare (salience 1))
   =>
   (read-from-symptoms-file symptom-details symptoms.txt)
   (read-from-diagnoses-file diagnoses.txt))

(defrule check-most-probable-diagnosis
   (not (diagnosis ?))
   =>
   (assert (check-most-probable)))

;;;; DIAGNOSES ;;;;
; (defrule confirm-rose-rust
;    ?f <- (check-rose-rust-diagnosis)
;    =>
;    (retract ?f)
;    (if (diagnose-plant rose rose-rust 0.7)
;       then
;       (assert (diagnosis "Your Roses seem to be Suffering from Rose Rust"))))


(defrule confirm-black-spot
    ?f <- (check-black-spot-diagnosis)
    =>
    (retract ?f)
    (if (diagnose-plant rose black-spot 0.7)
        then
        (assert (diagnosis "Your Roses seem to be Suffering from Black Spot")))
    (assert (check-most-probable)))

(defrule confirm-metallic-flea-beetle
   ?f <- (check-metallic-flea-beetle-diagnosis)
   =>
   (retract ?f)
   (if (diagnose-plant rose metallic-flea-beetle 0.7)
      then
      (assert (diagnosis "Your Roses seem to be Suffering from Metallic Flee Beetles"))))

(defrule find-most-probable-disease
    (not (diagnosis ?))
    ?f <- (check-most-probable)
    (disease-weight (disease-or-pest-name ?disease-or-pest-name1)
                    (plant-name ?plant-name)
                    (weight ?weight1))
   (not (disease-weight (weight ?weight2&:(> ?weight2 ?weight1))))
   =>
   ; (retract ?f)
   (printout t crlf crlf "********************DIAGNOSIS********************" crlf
                "We don't have sufficient information on the condition of your plant." crlf
    "But your " ?plant-name " most likey suffers from " ?disease-or-pest-name1 crlf))


;;;; Add Advice here, maybe? ;;;;

; Startup n Conclusion Rules

(defrule system-banner ""
    (declare (salience 10))
    =>
    (printout t crlf)
    (printout t "------------------------------------------------------" crlf)
    (printout t "        Horticulture Diagnosis Expert System" crlf)
    (printout t "------------------------------------------------------")
    (printout t crlf crlf))

(defrule determine-analysis "Rules for when no analysis mode has been set"
    (declare (salience 9))
    (not (analysis ?))
    =>
    (analysis-mode (yes-or-no-p "Would you like to activate Analysis Mode to see how the diagnosis is derived? (yes/no)? "))
    (printout t "" crlf)
    (assert (analysis)))

(defrule print-diagnosis ""
    (declare (salience 10))
    (diagnosis ?item)
    =>
    (printout t crlf crlf)
    (printout t "---------------------DIAGNOSIS--------------------")
    (printout t crlf crlf)
    (format t " %s%n%n" ?item))
