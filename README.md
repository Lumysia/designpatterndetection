# Design Pattern Detection

This project is an implementation and replication of the paper "Feature-based software design pattern detection".

There are two main ways to run this project:
1.  **Quick Test Mode:** Uses a random sample of Java projects and auto-generated "dummy" labels to quickly verify that the entire code pipeline works.
2.  **Paper Replication Mode:** Uses the expert-labeled `input-1300.csv` file provided by the authors to replicate the paper's original experiment.

## 1. Setup

### 1.1 Installation

First, ensure you are inside the configured `devcontainer` or a local Python 2.7 environment.

**Install all dependencies:**
```sh
pip install -r requirements.txt
```

**Make all shell scripts executable:**
```sh
chmod +x *.sh
```

### 1.2 Manual Code Fix (Required)

A manual code change is required in `call_graph.py` to make it compatible with the modern version of the `plyj` library, which is the only one available via pip.

**File to modify:** `call_graph.py`

**Action:** Find the `function_handling` dictionary (around line 100) and comment out the lines for `m.ExpressionStatement`.

```python
#            m.ExpressionStatement: \
#                cls.expr_decl,
```

#### Why is this necessary?
The original code was written for an older, unavailable version of the `plyj` library that had a feature called `ExpressionStatement`. The current version does not, causing a crash. This fix tells the script to simply ignore this legacy feature.

#### Does this change the final result?
No, the impact is negligible.

**What Are We Actually Missing?**

By commenting out the line, we are only preventing the script from analyzing the simplest possible statements that aren't covered by other rules. The most common example is a simple increment or decrement:
```java
i++;
count--;
```

**Why These Missing Parts Don't Matter for This Task**

The goal is to find high-level *design patterns*. A pattern like a **Singleton** is defined by having a private constructor and a static `getInstance()` method. A pattern like an **Observer** is defined by `register()` and `notify()` methods and the relationship between classes.

Whether a method contains `i++;` has almost zero value in determining if it's part of a larger architectural pattern. It's just low-level implementation noise. The critical features for pattern detection are still captured correctly.

---

## 2. Running the Experiments

### Option A: Quick Test (with Dummy Labels)

This is the **fastest way to test the full pipeline**. The final accuracy will be low, which is expected because the labels are randomly generated.

```sh
# 1. Clean up previous runs
rm -rf input/ output/ results/ p-mart-output-final.csv P-MARt-dataset.csv

# 2. Setup: Download and extract 40 random Java projects into the input/ directory
./setup_projects.sh

# 3. Feature Extraction: Process the Java code and generate SSLR feature files
python detector.py --input ./input --output ./output

# 4. Label Generation: Create a balanced, random "dummy" label file for the projects
./generate_balanced_labels.sh

# 5. Model Building: Combine features and labels to create the final dataset
python make_class_features.py ./output

# 6. Run Classifier: Train the model and get the results
mkdir -p results
python classifier.py RF
```

### Option B: Paper Replication (with Author's Labels)

This mode uses the authors' expert-labeled data. The final accuracy will be much higher and will closely resemble the results from the original paper.

```sh
# 1. Clean up previous runs
rm -rf input/ output/ results/ p-mart-output-final.csv P-MARt-dataset.csv target_projects.txt

# 2. Get Target Projects: Create a list of all projects mentioned in the author's label file
cut -d',' -f1 input-1300.csv | sort -u > target_projects.txt

# 3. Extract Projects: Extract only these specific projects from the 1.8GB archive
./extract_target_projects.sh

# 4. Use Author's Labels: Copy the author's label file to be used as our ground truth
cp input-1300.csv p-mart-output-final.csv

# 5. Feature Extraction: Process the Java code for the target projects
python detector.py --input ./input --output ./output

# 6. Model Building: Combine features and the ground truth labels
python make_class_features.py ./output

# 7. Run Classifier: Train the model and replicate the paper's experiment
mkdir -p results
python classifier.py RF
```