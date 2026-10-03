import os
import json
import random

import numpy as np
import tensorflow as tf

from PIL import Image

from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix

import matplotlib.pyplot as plt


# ============================================================
# SETTINGS
# ============================================================

DATASET_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\Comprehensive Facial Thermal Dataset"

MODEL_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnetb0_stress.keras"

HEAD_WEIGHTS_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnet_head.weights.h5"

FINE_WEIGHTS_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnet_best.weights.h5"

CLASS_NAMES_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_class_names.json"

CONFUSION_MATRIX_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnet_confusion_matrix.png"

ACCURACY_GRAPH_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnet_accuracy.png"

LOSS_GRAPH_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnet_loss.png"

REPORT_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnet_classification_report.txt"


# ============================================================
# TRAINING SETTINGS
# ============================================================

IMG_SIZE = 160

BATCH_SIZE = 16

HEAD_EPOCHS = 15

FINE_TUNE_EPOCHS = 50

SEED = 42


# ============================================================
# RANDOM SEED
# ============================================================

random.seed(SEED)

np.random.seed(SEED)

tf.random.set_seed(SEED)


# ============================================================
# CHECK DATASET
# ============================================================

print("\n==============================================")
print("CHECKING DATASET")
print("==============================================")

print("Dataset path:")
print(DATASET_PATH)

if not os.path.exists(DATASET_PATH):

    print("\nERROR: Dataset path does not exist.")

    print(DATASET_PATH)

    exit()


print("\nDataset path found.")


# ============================================================
# TENSORFLOW VERSION
# ============================================================

print("\n==============================================")
print("TENSORFLOW INFORMATION")
print("==============================================")

print("TensorFlow version:", tf.__version__)

try:

    print("Keras version:", tf.keras.__version__)

except:

    print("Keras version: unavailable")


# ============================================================
# GPU CHECK
# ============================================================

print("\n==============================================")
print("CHECKING GPU")
print("==============================================")

gpus = tf.config.list_physical_devices("GPU")

if gpus:

    print("GPU detected.")

    for gpu in gpus:

        print(gpu)

else:

    print("No GPU detected.")

    print("Training will use CPU.")


# ============================================================
# EMOTION MAPPING
# ============================================================
#
# Stress:
# angry
# disgust
# fear
# sad
#
# Non-Stress:
# happy
# neutral
#
# Ignored:
# surprise
#
# IMPORTANT:
# This is an emotion-derived proxy for stress.
# It is NOT a clinically validated stress label.
# ============================================================

STRESS_EMOTIONS = {

    "angry",
    "disgust",
    "fear",
    "sad"

}

NON_STRESS_EMOTIONS = {

    "happy",
    "neutral"

}

IGNORE_EMOTIONS = {

    "surprise"

}


# ============================================================
# IMAGE EXTENSIONS
# ============================================================

IMAGE_EXTENSIONS = {

    ".jpg",
    ".jpeg",
    ".png",
    ".bmp",
    ".webp"

}


# ============================================================
# FIND DATASET IMAGES
# ============================================================

def find_images():

    images = []

    labels = []

    emotion_counts = {}


    print("\n==============================================")
    print("SEARCHING DATASET")
    print("==============================================")


    for root, dirs, files in os.walk(DATASET_PATH):

        path_parts = [

            x.lower()

            for x in os.path.normpath(root).split(os.sep)

        ]


        emotion = None

        original_emotion = None


        # ----------------------------------------------------
        # FIND EMOTION FOLDER
        # ----------------------------------------------------

        for part in path_parts:

            if part in STRESS_EMOTIONS:

                emotion = "stress"

                original_emotion = part

                break


            if part in NON_STRESS_EMOTIONS:

                emotion = "non_stress"

                original_emotion = part

                break


            if part in IGNORE_EMOTIONS:

                emotion = None

                original_emotion = part

                break


        if emotion is None:

            continue


        # ----------------------------------------------------
        # FIND IMAGES
        # ----------------------------------------------------

        for file in files:

            extension = os.path.splitext(

                file

            )[1].lower()


            if extension in IMAGE_EXTENSIONS:

                image_path = os.path.join(

                    root,

                    file

                )


                images.append(

                    image_path

                )


                labels.append(

                    emotion

                )


                if original_emotion not in emotion_counts:

                    emotion_counts[original_emotion] = 0


                emotion_counts[original_emotion] += 1


    print("\nOriginal emotion folders:")


    for emotion, count in sorted(

        emotion_counts.items()

    ):

        print(

            emotion,

            ":",

            count

        )


    return images, labels


# ============================================================
# LOAD IMAGE PATHS
# ============================================================

image_paths, labels = find_images()


# ============================================================
# DATASET INFORMATION
# ============================================================

print("\n==============================================")
print("DATASET INFORMATION")
print("==============================================")


total_images = len(

    image_paths

)


stress_count = labels.count(

    "stress"

)


non_stress_count = labels.count(

    "non_stress"

)


print(

    "Total usable images:",

    total_images

)


print(

    "Stress images:",

    stress_count

)


print(

    "Non-stress images:",

    non_stress_count

)


if total_images == 0:

    print("\nERROR: No usable images found.")

    exit()


# ============================================================
# CONVERT LABELS TO NUMBERS
# ============================================================

label_values = []


for label in labels:

    if label == "non_stress":

        label_values.append(0)

    else:

        label_values.append(1)


image_paths = np.array(

    image_paths

)


label_values = np.array(

    label_values,

    dtype=np.int32

)


# ============================================================
# TRAIN / VALIDATION / TEST SPLIT
# ============================================================

print("\n==============================================")
print("CREATING DATA SPLIT")
print("==============================================")


# 70% TRAIN
# 15% VALIDATION
# 15% TEST

X_train, X_temp, y_train, y_temp = train_test_split(

    image_paths,

    label_values,

    test_size=0.30,

    random_state=SEED,

    stratify=label_values

)


X_val, X_test, y_val, y_test = train_test_split(

    X_temp,

    y_temp,

    test_size=0.50,

    random_state=SEED,

    stratify=y_temp

)


print(

    "Training images:",

    len(X_train)

)


print(

    "Validation images:",

    len(X_val)

)


print(

    "Testing images:",

    len(X_test)

)


print("\nTraining class distribution:")

print(

    "Non-Stress:",

    np.sum(y_train == 0)

)

print(

    "Stress:",

    np.sum(y_train == 1)

)


print("\nValidation class distribution:")

print(

    "Non-Stress:",

    np.sum(y_val == 0)

)

print(

    "Stress:",

    np.sum(y_val == 1)

)


print("\nTest class distribution:")

print(

    "Non-Stress:",

    np.sum(y_test == 0)

)

print(

    "Stress:",

    np.sum(y_test == 1)

)


# ============================================================
# IMAGE LOADING USING PIL
# ============================================================

def load_image_with_pil(path):

    path = path.numpy().decode("utf-8")


    try:

        image = Image.open(path)

        # Convert 1, 2, 3 or 4 channel images to RGB.
        image = image.convert("RGB")

        image = image.resize(

            (

                IMG_SIZE,

                IMG_SIZE

            ),

            Image.Resampling.BILINEAR

        )


        image = np.array(

            image,

            dtype=np.float32

        )


        # ----------------------------------------------------
        # THERMAL MIN-MAX NORMALIZATION
        # ----------------------------------------------------

        image_min = np.min(image)

        image_max = np.max(image)


        if image_max > image_min:

            image = (

                image - image_min

            ) / (

                image_max - image_min

            )

        else:

            image = image / 255.0


        return image.astype(

            np.float32

        )


    except Exception as e:

        print("\nERROR READING IMAGE:")

        print(path)

        print(e)


        return np.zeros(

            (

                IMG_SIZE,

                IMG_SIZE,

                3

            ),

            dtype=np.float32

        )


# ============================================================
# TENSORFLOW IMAGE LOADER
# ============================================================

def load_image(path, label):

    image = tf.py_function(

        func=load_image_with_pil,

        inp=[path],

        Tout=tf.float32

    )


    image.set_shape(

        (

            IMG_SIZE,

            IMG_SIZE,

            3

        )

    )


    return image, label


# ============================================================
# DATA AUGMENTATION
# ============================================================

data_augmentation = tf.keras.Sequential(

    [

        tf.keras.layers.RandomFlip(

            "horizontal"

        ),

        tf.keras.layers.RandomRotation(

            0.10

        ),

        tf.keras.layers.RandomZoom(

            height_factor=(-0.10, 0.15),

            width_factor=(-0.10, 0.15)

        ),

        tf.keras.layers.RandomTranslation(

            height_factor=0.08,

            width_factor=0.08

        ),

        tf.keras.layers.RandomContrast(

            0.20

        )

    ],

    name="thermal_augmentation"

)


# ============================================================
# AUGMENTATION FUNCTION
# ============================================================

def augment_image(image, label):

    image = data_augmentation(

        image,

        training=True

    )


    return image, label


# ============================================================
# CREATE DATASETS
# ============================================================

print("\n==============================================")
print("CREATING TF.DATA DATASETS")
print("==============================================")


train_dataset = tf.data.Dataset.from_tensor_slices(

    (

        X_train,

        y_train

    )

)


val_dataset = tf.data.Dataset.from_tensor_slices(

    (

        X_val,

        y_val

    )

)


test_dataset = tf.data.Dataset.from_tensor_slices(

    (

        X_test,

        y_test

    )

)


# ============================================================
# TRAIN DATASET
# ============================================================

train_dataset = train_dataset.map(

    load_image,

    num_parallel_calls=tf.data.AUTOTUNE

)


train_dataset = train_dataset.map(

    augment_image,

    num_parallel_calls=tf.data.AUTOTUNE

)


train_dataset = train_dataset.shuffle(

    1500,

    seed=SEED,

    reshuffle_each_iteration=True

)


train_dataset = train_dataset.batch(

    BATCH_SIZE

)


train_dataset = train_dataset.prefetch(

    tf.data.AUTOTUNE

)


# ============================================================
# VALIDATION DATASET
# ============================================================

val_dataset = val_dataset.map(

    load_image,

    num_parallel_calls=tf.data.AUTOTUNE

)


val_dataset = val_dataset.batch(

    BATCH_SIZE

)


val_dataset = val_dataset.prefetch(

    tf.data.AUTOTUNE

)


# ============================================================
# TEST DATASET
# ============================================================

test_dataset = test_dataset.map(

    load_image,

    num_parallel_calls=tf.data.AUTOTUNE

)


test_dataset = test_dataset.batch(

    BATCH_SIZE

)


test_dataset = test_dataset.prefetch(

    tf.data.AUTOTUNE

)


# ============================================================
# TEST IMAGE PIPELINE
# ============================================================

print("\n==============================================")
print("TESTING IMAGE PIPELINE")
print("==============================================")


for images, labels_batch in train_dataset.take(1):

    print(

        "Image shape:",

        images.shape

    )

    print(

        "Label shape:",

        labels_batch.shape

    )

    print(

        "Channels:",

        images.shape[-1]

    )

    print(

        "Minimum pixel value:",

        tf.reduce_min(images).numpy()

    )

    print(

        "Maximum pixel value:",

        tf.reduce_max(images).numpy()

    )


# ============================================================
# CLASS WEIGHTS
# ============================================================

stress_train_count = np.sum(

    y_train == 1

)


non_stress_train_count = np.sum(

    y_train == 0

)


total_train = len(

    y_train

)


class_weight = {

    0: float(

        total_train /

        (

            2 *

            non_stress_train_count

        )

    ),

    1: float(

        total_train /

        (

            2 *

            stress_train_count

        )

    )

}


print("\n==============================================")
print("CLASS BALANCING")
print("==============================================")


print(

    "Non-Stress weight:",

    class_weight[0]

)


print(

    "Stress weight:",

    class_weight[1]

)


# ============================================================
# CREATE EFFICIENTNETB0
# ============================================================

print("\n==============================================")
print("CREATING EFFICIENTNETB0")
print("==============================================")


# IMPORTANT:
# No "name=" parameter here because your older
# Keras version does not support it.

base_model = tf.keras.applications.EfficientNetB0(

    include_top=False,

    weights="imagenet",

    input_shape=(

        IMG_SIZE,

        IMG_SIZE,

        3

    )

)


print(

    "EfficientNetB0 created successfully."

)


# ============================================================
# FREEZE BASE MODEL
# ============================================================

base_model.trainable = False


# ============================================================
# MODEL INPUT
# ============================================================

inputs = tf.keras.Input(

    shape=(

        IMG_SIZE,

        IMG_SIZE,

        3

    ),

    name="thermal_input"

)


# ============================================================
# RESTORE 0-1 TO 0-255
# ============================================================

x = tf.keras.layers.Rescaling(

    255.0,

    name="restore_255"

)(inputs)


# ============================================================
# EFFICIENTNET BASE
# ============================================================

x = base_model(

    x,

    training=False

)


# ============================================================
# GLOBAL AVERAGE POOLING
# ============================================================

x = tf.keras.layers.GlobalAveragePooling2D(

    name="global_average_pooling"

)(x)


# ============================================================
# BATCH NORMALIZATION
# ============================================================

x = tf.keras.layers.BatchNormalization(

    name="head_batch_norm"

)(x)


# ============================================================
# DENSE 256
# ============================================================

x = tf.keras.layers.Dense(

    256,

    activation="relu",

    name="dense_256"

)(x)


# ============================================================
# DROPOUT
# ============================================================

x = tf.keras.layers.Dropout(

    0.45,

    name="dropout_45"

)(x)


# ============================================================
# DENSE 64
# ============================================================

x = tf.keras.layers.Dense(

    64,

    activation="relu",

    name="dense_64"

)(x)


# ============================================================
# DROPOUT
# ============================================================

x = tf.keras.layers.Dropout(

    0.30,

    name="dropout_30"

)(x)


# ============================================================
# OUTPUT
# ============================================================

outputs = tf.keras.layers.Dense(

    1,

    activation="sigmoid",

    name="stress_output"

)(x)


# ============================================================
# CREATE MODEL
# ============================================================

model = tf.keras.Model(

    inputs,

    outputs

)


print("\nEfficientNetB0 stress model created successfully.")


# ============================================================
# MODEL SUMMARY
# ============================================================

print("\n==============================================")
print("MODEL SUMMARY")
print("==============================================")


model.summary()


# ============================================================
# STAGE 1 COMPILE
# ============================================================

model.compile(

    optimizer=tf.keras.optimizers.Adam(

        learning_rate=float(0.0003)

    ),

    loss="binary_crossentropy",

    metrics=[

        tf.keras.metrics.BinaryAccuracy(

            name="accuracy"

        ),

        tf.keras.metrics.Precision(

            name="precision"

        ),

        tf.keras.metrics.Recall(

            name="recall"

        )

    ]

)


# ============================================================
# STAGE 1 CALLBACKS
# ============================================================

head_callbacks = [

    tf.keras.callbacks.ModelCheckpoint(

        HEAD_WEIGHTS_PATH,

        monitor="val_accuracy",

        save_best_only=True,

        save_weights_only=True,

        mode="max",

        verbose=1

    ),

    tf.keras.callbacks.EarlyStopping(

        monitor="val_loss",

        patience=5,

        restore_best_weights=True,

        verbose=1

    ),

    tf.keras.callbacks.ReduceLROnPlateau(

        monitor="val_loss",

        factor=0.5,

        patience=2,

        min_lr=float(0.000001),

        verbose=1

    )

]


# ============================================================
# STAGE 1 TRAINING
# ============================================================

print("\n==============================================")
print("STAGE 1 TRAINING")
print("EFFICIENTNETB0 FROZEN")
print("==============================================")


history_head = model.fit(

    train_dataset,

    validation_data=val_dataset,

    epochs=HEAD_EPOCHS,

    class_weight=class_weight,

    callbacks=head_callbacks,

    verbose=1

)


# ============================================================
# LOAD BEST STAGE 1 WEIGHTS
# ============================================================

print("\n==============================================")
print("LOADING BEST STAGE 1 WEIGHTS")
print("==============================================")


model.load_weights(

    HEAD_WEIGHTS_PATH

)


print(

    "Best Stage 1 weights loaded."

)


# ============================================================
# STAGE 2 FINE-TUNING
# ============================================================

print("\n==============================================")
print("STAGE 2 FINE-TUNING")
print("==============================================")


# Use the Python variable directly.
# Do NOT use:
#
# model.get_layer("efficientnetb0_base")
#
# because older Keras may not preserve the custom name.

base_model.trainable = True


# ============================================================
# CHOOSE FINE-TUNING START LAYER
# ============================================================

fine_tune_from = int(

    len(base_model.layers) * 0.60

)


print(

    "Total EfficientNet layers:",

    len(base_model.layers)

)


print(

    "Fine-tuning from layer:",

    fine_tune_from

)


# ============================================================
# FREEZE FIRST 60%
# ============================================================

for layer in base_model.layers[

    :fine_tune_from

]:

    layer.trainable = False


# ============================================================
# FREEZE BATCH NORMALIZATION
# ============================================================

for layer in base_model.layers:

    if isinstance(

        layer,

        tf.keras.layers.BatchNormalization

    ):

        layer.trainable = False


# ============================================================
# TRAINABLE PARAMETERS
# ============================================================

trainable_count = np.sum(

    [

        np.prod(

            v.shape

        )

        for v in model.trainable_weights

    ]

)


print(

    "Trainable parameters:",

    trainable_count

)


# ============================================================
# STAGE 2 COMPILE
# ============================================================

model.compile(

    optimizer=tf.keras.optimizers.Adam(

        learning_rate=float(0.00001)

    ),

    loss="binary_crossentropy",

    metrics=[

        tf.keras.metrics.BinaryAccuracy(

            name="accuracy"

        ),

        tf.keras.metrics.Precision(

            name="precision"

        ),

        tf.keras.metrics.Recall(

            name="recall"

        )

    ]

)


# ============================================================
# STAGE 2 CALLBACKS
# ============================================================

fine_callbacks = [

    tf.keras.callbacks.ModelCheckpoint(

        FINE_WEIGHTS_PATH,

        monitor="val_accuracy",

        save_best_only=True,

        save_weights_only=True,

        mode="max",

        verbose=1

    ),

    tf.keras.callbacks.EarlyStopping(

        monitor="val_loss",

        patience=8,

        restore_best_weights=True,

        verbose=1

    ),

    tf.keras.callbacks.ReduceLROnPlateau(

        monitor="val_loss",

        factor=0.5,

        patience=3,

        min_lr=float(0.0000001),

        verbose=1

    )

]


# ============================================================
# STAGE 2 TRAINING
# ============================================================

print("\n==============================================")
print("STARTING EFFICIENTNET FINE-TUNING")
print("==============================================")


history_fine = model.fit(

    train_dataset,

    validation_data=val_dataset,

    epochs=FINE_TUNE_EPOCHS,

    class_weight=class_weight,

    callbacks=fine_callbacks,

    verbose=1

)


# ============================================================
# LOAD BEST FINE-TUNED WEIGHTS
# ============================================================

print("\n==============================================")
print("LOADING BEST FINE-TUNED WEIGHTS")
print("==============================================")


model.load_weights(

    FINE_WEIGHTS_PATH

)


print(

    "Best fine-tuned weights loaded."

)


# ============================================================
# VALIDATION PREDICTIONS
# ============================================================

print("\n==============================================")
print("VALIDATION PREDICTIONS")
print("==============================================")


val_probability = model.predict(

    val_dataset,

    verbose=1

)


val_probability = val_probability.ravel()


# ============================================================
# FIND BEST VALIDATION THRESHOLD
# ============================================================

print("\n==============================================")
print("SEARCHING VALIDATION THRESHOLD")
print("==============================================")


best_threshold = 0.50

best_validation_accuracy = 0.0


for threshold in np.arange(

    0.30,

    0.71,

    0.01

):

    validation_prediction = (

        val_probability >= threshold

    ).astype(int)


    validation_accuracy = np.mean(

        validation_prediction == y_val

    )


    if validation_accuracy > best_validation_accuracy:

        best_validation_accuracy = validation_accuracy

        best_threshold = float(

            threshold

        )


print(

    "\nBest validation threshold:",

    round(

        best_threshold,

        2

    )

)


print(

    "Validation accuracy:",

    round(

        best_validation_accuracy * 100,

        2

    ),

    "%"

)


# ============================================================
# FINAL TEST EVALUATION
# ============================================================

print("\n==============================================")
print("FINAL TEST EVALUATION")
print("==============================================")


test_result = model.evaluate(

    test_dataset,

    verbose=1

)


print("\nKeras test metrics:")


for name, value in zip(

    model.metrics_names,

    test_result

):

    print(

        name,

        ":",

        value

    )


# ============================================================
# TEST PREDICTIONS
# ============================================================

print("\n==============================================")
print("GENERATING TEST PREDICTIONS")
print("==============================================")


test_probability = model.predict(

    test_dataset,

    verbose=1

)


test_probability = test_probability.ravel()


# ============================================================
# TEST CLASSIFICATION
# ============================================================

test_prediction = (

    test_probability >= best_threshold

).astype(int)


# ============================================================
# FINAL TEST ACCURACY
# ============================================================

test_accuracy = np.mean(

    test_prediction == y_test

)


print("\n==============================================")
print("FINAL TEST RESULT")
print("==============================================")


print(

    "Selected threshold:",

    round(

        best_threshold,

        2

    )

)


print(

    "Test accuracy:",

    round(

        test_accuracy * 100,

        2

    ),

    "%"

)


# ============================================================
# CLASSIFICATION REPORT
# ============================================================

print("\n==============================================")
print("CLASSIFICATION REPORT")
print("==============================================")


report = classification_report(

    y_test,

    test_prediction,

    target_names=[

        "Non-Stress",

        "Stress"

    ],

    digits=4

)


print(report)


# ============================================================
# SAVE CLASSIFICATION REPORT
# ============================================================

with open(

    REPORT_PATH,

    "w"

) as file:

    file.write(

        "EfficientNetB0 Thermal Stress Detection\n\n"

    )

    file.write(

        "Test Accuracy: "

        + str(

            round(

                test_accuracy * 100,

                2

            )

        )

        + "%\n\n"

    )

    file.write(

        "Validation Threshold: "

        + str(

            round(

                best_threshold,

                2

            )

        )

        + "\n\n"

    )

    file.write(report)


print(

    "Report saved:",

    REPORT_PATH

)


# ============================================================
# CONFUSION MATRIX
# ============================================================

print("\n==============================================")
print("CONFUSION MATRIX")
print("==============================================")


cm = confusion_matrix(

    y_test,

    test_prediction

)


print(cm)


plt.figure(

    figsize=(7, 6)

)


plt.imshow(

    cm,

    interpolation="nearest"

)


plt.title(

    "EfficientNetB0 Thermal Stress Detection"

)


plt.colorbar()


classes = [

    "Non-Stress",

    "Stress"

]


tick_marks = np.arange(

    len(classes)

)


plt.xticks(

    tick_marks,

    classes,

    rotation=45

)


plt.yticks(

    tick_marks,

    classes

)


for i in range(

    cm.shape[0]

):

    for j in range(

        cm.shape[1]

    ):

        plt.text(

            j,

            i,

            str(cm[i, j]),

            horizontalalignment="center"

        )


plt.ylabel(

    "Actual"

)


plt.xlabel(

    "Predicted"

)


plt.tight_layout()


plt.savefig(

    CONFUSION_MATRIX_PATH,

    dpi=200

)


plt.show()


# ============================================================
# COMBINE TRAINING HISTORY
# ============================================================

train_accuracy = []

val_accuracy = []

train_loss = []

val_loss = []


# ============================================================
# STAGE 1 HISTORY
# ============================================================

train_accuracy.extend(

    history_head.history.get(

        "accuracy",

        []

    )

)


val_accuracy.extend(

    history_head.history.get(

        "val_accuracy",

        []

    )

)


train_loss.extend(

    history_head.history.get(

        "loss",

        []

    )

)


val_loss.extend(

    history_head.history.get(

        "val_loss",

        []

    )

)


# ============================================================
# STAGE 2 HISTORY
# ============================================================

train_accuracy.extend(

    history_fine.history.get(

        "accuracy",

        []

    )

)


val_accuracy.extend(

    history_fine.history.get(

        "val_accuracy",

        []

    )

)


train_loss.extend(

    history_fine.history.get(

        "loss",

        []

    )

)


val_loss.extend(

    history_fine.history.get(

        "val_loss",

        []

    )

)


# ============================================================
# ACCURACY GRAPH
# ============================================================

plt.figure(

    figsize=(9, 6)

)


plt.plot(

    train_accuracy,

    label="Training Accuracy"

)


plt.plot(

    val_accuracy,

    label="Validation Accuracy"

)


plt.xlabel(

    "Epoch"

)


plt.ylabel(

    "Accuracy"

)


plt.title(

    "EfficientNetB0 Thermal Stress Accuracy"

)


plt.legend()


plt.grid()


plt.tight_layout()


plt.savefig(

    ACCURACY_GRAPH_PATH,

    dpi=200

)


plt.show()


# ============================================================
# LOSS GRAPH
# ============================================================

plt.figure(

    figsize=(9, 6)

)


plt.plot(

    train_loss,

    label="Training Loss"

)


plt.plot(

    val_loss,

    label="Validation Loss"

)


plt.xlabel(

    "Epoch"

)


plt.ylabel(

    "Loss"

)


plt.title(

    "EfficientNetB0 Thermal Stress Loss"

)


plt.legend()


plt.grid()


plt.tight_layout()


plt.savefig(

    LOSS_GRAPH_PATH,

    dpi=200

)


plt.show()


# ============================================================
# SAVE CLASS INFORMATION
# ============================================================

class_names = {

    "0": "non_stress",

    "1": "stress"

}


with open(

    CLASS_NAMES_PATH,

    "w"

) as file:

    json.dump(

        class_names,

        file,

        indent=4

    )


# ============================================================
# SAVE COMPLETE MODEL
# ============================================================

print("\n==============================================")
print("SAVING COMPLETE MODEL")
print("==============================================")


try:

    model.save(

        MODEL_PATH

    )


    print(

        "Complete model saved:",

        MODEL_PATH

    )


except Exception as e:

    print("\nWARNING: Complete .keras model could not be saved.")

    print(e)

    print("\nThe trained weights were already saved here:")

    print(FINE_WEIGHTS_PATH)


# ============================================================
# FINAL INFORMATION
# ============================================================

print("\n====================================================")

print("       EFFICIENTNETB0 TRAINING COMPLETED")

print("====================================================")


print("\nTotal images:")

print(total_images)


print("\nTraining images:")

print(len(X_train))


print("\nValidation images:")

print(len(X_val))


print("\nTest images:")

print(len(X_test))


print("\nValidation threshold:")

print(

    round(

        best_threshold,

        2

    )

)


print("\nFinal test accuracy:")

print(

    round(

        test_accuracy * 100,

        2

    ),

    "%"

)


print("\nBest fine-tuned weights:")

print(FINE_WEIGHTS_PATH)


print("\nClassification report:")

print(REPORT_PATH)


print("\nConfusion matrix:")

print(CONFUSION_MATRIX_PATH)


print("\nAccuracy graph:")

print(ACCURACY_GRAPH_PATH)


print("\nLoss graph:")

print(LOSS_GRAPH_PATH)


print("\n====================================================")

print("                    MODEL READY")

print("====================================================")