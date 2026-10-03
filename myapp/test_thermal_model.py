import os
import tensorflow as tf
from tensorflow.keras import layers, models


# ================================================================
# PATH
# ================================================================

WEIGHTS_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnet_best.weights.h5"

IMG_SIZE = 160


# ================================================================
# CREATE THERMAL MODEL
# ================================================================

def create_thermal_model():

    print("==============================================")
    print("CREATING THERMAL MODEL")
    print("==============================================")

    # ------------------------------------------------------------
    # INPUT
    # ------------------------------------------------------------

    inputs = layers.Input(
        shape=(IMG_SIZE, IMG_SIZE, 3),
        name="thermal_input"
    )

    # ------------------------------------------------------------
    # EFFICIENTNET B0
    # ------------------------------------------------------------

    base_model = tf.keras.applications.EfficientNetB0(
        include_top=False,
        weights="imagenet",
        input_shape=(IMG_SIZE, IMG_SIZE, 3)
    )

    # Important:
    # The trained weights file contains the layer name
    # "efficientnetb0"
    base_model._name = "efficientnetb0"

    # ------------------------------------------------------------
    # FINE TUNING CONFIGURATION
    # ------------------------------------------------------------

    base_model.trainable = True

    fine_tune_from = int(len(base_model.layers) * 0.60)

    for i, layer in enumerate(base_model.layers):

        if i < fine_tune_from:
            layer.trainable = False
        else:
            layer.trainable = True

        # BatchNormalization layers were frozen during training
        if isinstance(layer, tf.keras.layers.BatchNormalization):
            layer.trainable = False

    # ------------------------------------------------------------
    # RESTORE 255
    # ------------------------------------------------------------

    x = layers.Rescaling(
        255.0,
        name="restore_255"
    )(inputs)

    # ------------------------------------------------------------
    # EFFICIENTNET
    # ------------------------------------------------------------

    x = base_model(x)

    # ------------------------------------------------------------
    # GLOBAL AVERAGE POOLING
    # ------------------------------------------------------------

    x = layers.GlobalAveragePooling2D(
        name="global_average_pooling"
    )(x)

    # ------------------------------------------------------------
    # BATCH NORMALIZATION
    # ------------------------------------------------------------

    x = layers.BatchNormalization(
        name="head_batch_norm"
    )(x)

    # ------------------------------------------------------------
    # DENSE 256
    # ------------------------------------------------------------

    x = layers.Dense(
        256,
        activation="relu",
        name="dense_256"
    )(x)

    # ------------------------------------------------------------
    # DROPOUT 45
    # ------------------------------------------------------------

    x = layers.Dropout(
        0.45,
        name="dropout_45"
    )(x)

    # ------------------------------------------------------------
    # DENSE 64
    # ------------------------------------------------------------

    x = layers.Dense(
        64,
        activation="relu",
        name="dense_64"
    )(x)

    # ------------------------------------------------------------
    # DROPOUT 30
    # ------------------------------------------------------------

    x = layers.Dropout(
        0.30,
        name="dropout_30"
    )(x)

    # ------------------------------------------------------------
    # OUTPUT
    # ------------------------------------------------------------

    outputs = layers.Dense(
        1,
        activation="sigmoid",
        name="stress_output"
    )(x)

    # ------------------------------------------------------------
    # CREATE MODEL
    # ------------------------------------------------------------

    model = models.Model(
        inputs=inputs,
        outputs=outputs
    )

    print("Model created.")
    print("Layers:", len(model.layers))

    return model


# ================================================================
# CREATE MODEL
# ================================================================

model = create_thermal_model()


# ================================================================
# CHECK WEIGHTS FILE
# ================================================================

print()
print("==============================================")
print("LOADING TRAINED WEIGHTS")
print("==============================================")

print("Weights path:")
print(WEIGHTS_PATH)

if not os.path.exists(WEIGHTS_PATH):

    print()
    print("ERROR: Weights file does not exist.")
    print(WEIGHTS_PATH)

    raise FileNotFoundError(
        "Thermal weights file not found."
    )

print()
print("Weights file exists:", os.path.exists(WEIGHTS_PATH))
print(
    "Weights size:",
    os.path.getsize(WEIGHTS_PATH),
    "bytes"
)


# ================================================================
# LOAD TRAINED WEIGHTS
# ================================================================

try:

    model.load_weights(
        WEIGHTS_PATH,
        by_name=True,
        skip_mismatch=False
    )

    print()
    print("==============================================")
    print("WEIGHTS LOADED SUCCESSFULLY")
    print("==============================================")

except Exception as e:

    print()
    print("==============================================")
    print("WEIGHTS LOAD ERROR")
    print("==============================================")

    print(type(e).__name__)
    print(e)

    raise


# ================================================================
# MODEL SUMMARY
# ================================================================

print()
print("==============================================")
print("MODEL SUMMARY")
print("==============================================")

model.summary()


# ================================================================
# MODEL INFORMATION
# ================================================================

print()
print("==============================================")
print("MODEL INFORMATION")
print("==============================================")

print("Input shape:")
print(model.input_shape)

print()
print("Output shape:")
print(model.output_shape)

print()
print("Total parameters:")
print(model.count_params())


# ================================================================
# TEST MODEL WITH RANDOM IMAGE
# ================================================================
#
# This only checks whether the reconstructed model can perform
# a prediction after loading the trained weights.
#
# It is NOT an actual thermal image prediction.
#
# ================================================================

print()
print("==============================================")
print("TESTING MODEL PREDICTION")
print("==============================================")


try:

    # Create a dummy image
    test_image = tf.random.uniform(
        shape=(1, IMG_SIZE, IMG_SIZE, 3),
        minval=0.0,
        maxval=1.0,
        dtype=tf.float32
    )

    prediction = model.predict(
        test_image,
        verbose=0
    )

    score = float(prediction[0][0])

    print()
    print("Prediction successful.")

    print()
    print("Raw score:")
    print(score)

    # ------------------------------------------------------------
    # THRESHOLD
    # ------------------------------------------------------------

    THRESHOLD = 0.50

    if score >= THRESHOLD:

        status = "STRESS"

    else:

        status = "NON-STRESS"

    print()
    print("Threshold:")
    print(THRESHOLD)

    print()
    print("Predicted status:")
    print(status)


except Exception as e:

    print()
    print("==============================================")
    print("PREDICTION ERROR")
    print("==============================================")

    print(type(e).__name__)
    print(e)

    raise


# ================================================================
# FINAL RESULT
# ================================================================

print()
print("==============================================")
print("THERMAL MODEL TEST COMPLETED")
print("==============================================")

print()
print("Architecture created successfully.")
print("Trained weights loaded successfully.")
print("Prediction test completed successfully.")

print()
print("Weights file used:")
print(WEIGHTS_PATH)

print()
print("The complete .keras/.h5 model does NOT need to be saved.")

print()
print("Django should reconstruct the same architecture")
print("and load this weights file directly.")

print()
print("READY FOR DJANGO")
print("==============================================")