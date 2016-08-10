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
        then cabbage 
    else roses))))
    )

;;;; Query Rules ;;;;
;____________________;

;;; 

(defrule determine-plant ""
    (not (plant-name ?))
    (not (disease ?))
    =>
    (assert (plant-name (which-plant "Which type of plant has a problem?  (1.cabbage 2.banana 3.maize 4.roses)? "))))


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
