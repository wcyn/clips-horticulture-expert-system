# clips-horticulture-expert-system
A Knowledge Based System (KBS) using CLIPS for Horticulture disease and pest diagnosis

View the data about the symptoms from the [symptoms file](https://github.com/wcyn/clips-horticulture-expert-system/blob/master/symptoms.md)

## How to run this program

Clone the repo: 
```
git clone https://github.com/wcyn/clips-horticulture-expert-system
```
Run the [CLIPS Program](https://sourceforge.net/projects/clipsrules/): 

> Click on File -> Load, then browse to the directory with the cloned files.  
 Click on `diagnosis_rules.CLP` file. Then click Open.

On the CLIPS command line, type:
``` 
CLIPS> (run) 
```

## How the weights work

Each symptom has a weight, depending on the disease or pest.  
The weights of each group of symptoms for a certain disease is obtained by diving `100` by the total number of symptoms for that disease.

For example, Rose Rust has four symptoms, therefore, `100 / 4` gives us a weight of `25` for each symptom.
The `5` Black Spot symptoms each have a weight of `20`, since `100 / 5` is, well, `20`.

Eventually, the weights for the groups of symptoms for a pest or disease are added together. Only the weights of the symptoms that are present are added up.

For example, if `3` out of `4` symptoms for the Rose Rust disease are present, and each symptom has a weight of `25` (`100 / 4`), then the total weight will be `75`.
When the `threshold` of the Rose Rust disease is defined as `70`, the diagnosis for Rose Rust will be positive, since `75` is greater than `70`.

If only `2` out `4` Rose Rust symptoms are present, that gives us a total weight of `50` (`25 *2`), which is less than `70`, and thus the program fires the rules for the next disease or pest.

## Template Definitions

<a name="symptom-details"/>
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
-- Get all the weights of facts in the `symptoms-details` [template](#symptom-details) whose `prescence` is `yes`, `plant-name` is <argument specified for `plant-name`> and whose `disease-or-pest` is <argument specified for `disease-or-pest`>  
-- Add up those weights and assign them to `weight`    
-- If `weight` is greater than <argument given for `threshold`>, then return TRUE


## Query Rules
### `defrule determine-plant`
__Description__: Determines the type of plant affected  
__Rule conditions__: Only fires if __no__ `diagnosis` has been reached, and __no__ `plant-name` has been provided by the user

## Query Rules for Specific Plants
A lot of repetition is involved here. Each symptom rule essentially has the same structure. Here's an example for the first symptom of the __Rose Rust__ disease. 

### `defrule determine-yellow-patch-leaves`
__Description__: Determines whether the rose plant has yellow patches on its leaves  
__Rule conditions__: Only fires if __no__ `diagnosis` has been reached __and__ `plant-name` is `rose`  
If these conditions are reached, assert the `symptom-details` facts. Also ,ask the user a yes / no question and assign the answer to `presence`.

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
                (yes-or-no-p "Does the plant have yellow patches on its leaves? (yes/no)? "))
            (weight 25))))
```

## Diagnosis Rules
_to be continued..
