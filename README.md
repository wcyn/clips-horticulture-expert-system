# clips-horticulture-expert-system
A Knowledge Based System (KBS) using CLIPS for Horticulture disease and pest diagnosis that __automatically generates rules__ from a .txt file. Read more about the [automation](#automated-query-rules-for-specific-symptoms)

View the data about the symptoms from the [symptoms documentation](https://github.com/wcyn/clips-horticulture-expert-system/blob/master/symptoms.md)

## How to run this program

Clone the repo: 
```
git clone https://github.com/wcyn/clips-horticulture-expert-system
```
Run the [CLIPS Program](https://sourceforge.net/projects/clipsrules/): 

&emsp;Click on File -> Load, then browse to the directory with the cloned files.  
&emsp;Click on `diagnosis_rules_automated.CLP` file. Then click Open.

On the CLIPS command line, type:
``` 
CLIPS> (run) 
```

## Table of Contents
[How the Weights Work](#how-the-weights-work)  
[Template Definitions](#template-definitions)  
&emsp;[`deftemplate symptom-details`](#deftemplate-symptom-details)  
&emsp;[`deftemplate disease-weight`](#deftemplate-disease-weight)  
[Function Definitions](#function-definition)  
&emsp;[`deffunction ask-question`](#deffunction-ask-question)  
&emsp;[`deffunction yes-or-no-p`](#deffunction-yes-or-no-p)  
&emsp;[`deffunction which-plant`](#deffunction-which-plant)  
&emsp;[`deffunction diagnose-plant`](#deffunction-diagnose-plant)  
[Query Rules](#query-rules)  
&emsp;[`defrule determine-plant`](#defrule-determine-plant)  
[Automated Query Rules for Specific Symptoms](#automated-query-rules-for-specific-symptoms)  
&emsp;[`deffunction read-from-file`](#deffunction-read-from-file)  
&emsp;[`deffunction create-query-rules`](#deffunction-create-query-rules)  
&emsp;&emsp;[`defrule determine-yellow-patch-leaves`](#defrule-determine-yellow-patch-leaves)  
[Diagnosis Rules](#diagnosis-rules)


## How the weights work

Each symptom has a weight, depending on the disease or pest.  
The weights of each group of symptoms for a certain disease is obtained by diving `100` by the total number of symptoms for that disease.

For example, Rose Rust has four symptoms, therefore, `100 / 4` gives us a weight of `25` for each symptom.
The `5` Black Spot symptoms each have a weight of `20`, since `100 / 5` is, well, `20`.

Eventually, the weights for the groups of symptoms for a pest or disease are added together. Only the weights of the symptoms that are present are added up.

For example, if `3` out of `4` symptoms for the Rose Rust disease are present, and each symptom has a weight of `25` (`100 / 4`), then the total weight will be `75` (`3 * 25`).
When the `threshold` of the Rose Rust disease is defined as `70`, the diagnosis for Rose Rust will be positive, since `75` is greater than `70`.

If only `2` out `4` Rose Rust symptoms are present, that gives us a total weight of `50` (`25 * 2`), which is less than `70`, and thus the program fires the rules for the next disease or pest.

## Template Definitions
These provide a framework to hold the various groups of data items.
### `deftemplate symptom-details`
__Description__: Defines the types of data describing the details of a symptom  
__Slots__:  
-- `symptom-name` - Name of the Symptom  
-- `plant-name` - The name of the plant  
-- `disease-or-pest` - What disease or pest the symptoms belongs to  
-- `prescence` - If the symptom is present in the plant or not. Can be `yes` or `no`. Default is `no`  
-- `weight` - The weight that the symptom contributes to the overal disease or pest

### `deftemplate disease-weight`
__Description__: Defines the name of the disease and the total weight it has after adding up all its symptom's weights  
__Slots__:   
-- `disease-or-pest-name` - Name of the disease or pest  
-- `plant` - Name of the plant that the disease belongs to  
-- `weight` - The total weight that the symptoms of the disease contribute. It's an addition of __only__ the present symptoms.

## Function Definitions

### `deffunction ask-question` 
__Description__: Asks a question  
__Arguments__:  
-- `question` - The question to ask the user  
-- `allowed-values` - Input values accepted for the question asked  
__Steps__:  
-- Printout the `question`  
-- Get user input and store it in `answer`  
-- If `answer` is not in `allowed-values`, keep asking the `question`  
-- Finally, return `answer`

### `deffunction yes-or-no-p`
__Description__: Asks question and gets yes or no response from user  
__Arguments__:  
-- `question` - The question to ask the user  
__Steps__:  
-- Get yes or no response from user and store that in `response`  
-- Return `yes` if response is `yes` and `no` if response is `no`

### `deffunction which-plant`
__Description__: Finds what plant is affected  
__Arguments__:  
-- `question` - The question to ask the user  
__Steps__:   
-- Get number / identity of plant affected from the user and store that in `response`  
-- Return `cabbage` if response is `1`, `banana` if `2` and so on..

### `deffunction diagnose-plant` 
__Description__: Get weight totals of the group of symptoms for a disease or pest and give a positive diagnosis if threshold is exceeded  
__Arguments__:  
-- `plant-name` - The name of the plant  
-- `disease-or-pest` - What disease or pest the symptoms belongs to  
-- `threshold` - The total weight that must be exceeded for a certain disease or pest to be the accepted diagnosis  
__Steps__:  
-- Initialize the `weight` to zero  
-- Get all the weights of facts in the `symptoms-details` [template](#symptom-details) whose `prescence` is `yes`, `plant-name` is [argument specified for `plant-name`] and whose `disease-or-pest` is [argument specified for `disease-or-pest`]  
-- Add up those weights and assign them to `weight`    b
-- If `weight` is greater than [argument given for `threshold`], then return TRUE


## Query Rules
### `defrule determine-plant`
__Description__: Determines the type of plant affected  
__Rule conditions__: Only fires if __no__ `diagnosis` has been reached, and __no__ `plant-name` has been provided by the user

## Automated Query Rules for Specific Symptoms
Rules used to query the user about the various [symptoms](https://github.com/wcyn/clips-horticulture-expert-system/blob/master/symptoms.md) are automatically generated from the [`symptoms.txt`](https://github.com/wcyn/clips-horticulture-expert-system/blob/master/symptoms.txt) file.
For all the rules to be generated, the function [`read-from-file`](#deffunction read-from-file) is called, which loops through the file extracting the data that is needed to create the rules.

### `deffunction read-from-file`
__Description__: Loop through the text file with the data and use the [`create-query-rules`](#deffunction-create-query-rules) function to create rules for each symptom   
__Arguments__:  
-- `template` - The [template](#template-details) to use for the details of the symptoms  
-- `file` - The name of the file containing the data  
```
(deffunction read-from-file (?template ?file)
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
            (bind ?plant-name (read file-data)) ; Read plant name of the group of symptoms
            (bind ?disease-or-pest (read file-data)) ; Read disease or pest name of the next group of symptoms
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
```

### `deffunction create-query-rules`
__Description__: Generate a rule to query the user about a symptom   
__Arguments__:  
-- `template` - The [template](#template-details) to use for the details of the symptoms  
-- `plant-name` - The name of the plant  
-- `disease-or-pest` - What disease or pest the symptoms belongs to  
-- `symptom` - The name of the symptom to ask the user about  
-- `qn` - The question to ask the user  
-- `weight` - The weight that the symptom contributes to the overal disease or pest  

The function code is as shown:
```
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
```
If this function is run as such (remember that it depends on the `yes-or-no-p` function):
```
CLIPS> (create-query-rules symptom-details rose rose-rust yellow-patch-leaves "\"Yellow patched leaves? \"" 20)
```

It will generate a rule called `determine-yellow-patch-leaves` that looks like this:

#### `defrule determine-yellow-patch-leaves`
__Description__: Determines whether the rose plant has yellow patches on its leaves  
__Rule conditions__: Only fires if __no__ `diagnosis` has been reached __and__ `plant-name` is `rose`  
If these conditions are reached, assert the [`symptom-details`](#deftemplate-symptom-details) facts. Also ,ask the user a yes / no question and assign the answer to `presence`.

```
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
                (yes-or-no-p "Yellow patched leaves? "))
            (weight 25))))
```

## Diagnosis Rules
_to be continued.._
