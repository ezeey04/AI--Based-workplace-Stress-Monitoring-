import os
import cv2
import json
import time
import numpy as np
import tensorflow as tf


# ============================================================
# PATHS
# ============================================================

MODEL_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnetb0_stress.keras"

BEST_WEIGHTS_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnet_best.weights.h5"

HEAD_WEIGHTS_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_efficientnet_head.weights.h5"

CLASS_NAMES_PATH = r"C:\Users\razee\PycharmProjects\stress_monitoring\myapp\thermal_class_names.json"


# ============================================================
# SETTINGS
# ============================================================

IMG_SIZE = 160

CAMERA_INDEX = 0

CAPTURE_INTERVAL = 10

# Put your actual "Best validation threshold" here
THRESHOLD = 0.50


# ============================================================
# CHECK FILES
# ============================================================

print()
print("==============================================")
print("CHECKING MODEL FILES")
print("==============================================")

print()
print("Complete model:")
print(MODEL_PATH)

print()
print("Best weights:")
print(BEST_WEIGHTS_PATH)

print()
print("Head weights:")
print(HEAD_WEIGHTS_PATH)


print()
print("Complete model exists:", os.path.exists(MODEL_PATH))
print("Best weights exists:", os.path.exists(BEST_WEIGHTS_PATH))
print("Head weights exists:", os.path.exists(HEAD_WEIGHTS_PATH))


# ============================================================
# LOAD COMPLETE MODEL
# ============================================================

model = None


if os.path.exists(MODEL_PATH):

    print()
    print("==============================================")
    print("LOADING COMPLETE MODEL")
    print("==============================================")

    try:

        model = tf.keras.models.load_model(
            MODEL_PATH,
            compile=False
        )

        print()
        print("Complete model loaded successfully.")

        print(
            "Input shape:",
            model.input_shape
        )

        print(
            "Output shape:",
            model.output_shape
        )

        print(
            "Number of layers:",
            len(model.layers)
        )

    except Exception as e:

        print()
        print("Complete .keras model could not be loaded.")

        print()
        print("ERROR:")
        print(e)


# ============================================================
# IF COMPLETE MODEL FAILED
# CREATE SAME ARCHITECTURE
# ============================================================

if model is None:

    print()
    print("==============================================")
    print("CREATING MODEL ARCHITECTURE")
    print("==============================================")


    # --------------------------------------------------------
    # EFFICIENTNET BASE
    # --------------------------------------------------------

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
        "EfficientNetB0 created."
    )


    # --------------------------------------------------------
    # FREEZE BASE
    # --------------------------------------------------------

    base_model.trainable = True


    fine_tune_from = int(
        len(base_model.layers) * 0.60
    )


    for layer in base_model.layers[
        :fine_tune_from
    ]:

        layer.trainable = False


    # --------------------------------------------------------
    # FREEZE BATCH NORMALIZATION
    # --------------------------------------------------------

    for layer in base_model.layers:

        if isinstance(
            layer,
            tf.keras.layers.BatchNormalization
        ):

            layer.trainable = False


    # --------------------------------------------------------
    # INPUT
    # --------------------------------------------------------

    inputs = tf.keras.Input(
        shape=(
            IMG_SIZE,
            IMG_SIZE,
            3
        ),
        name="thermal_input"
    )


    # --------------------------------------------------------
    # RESTORE 0-255
    # --------------------------------------------------------

    x = tf.keras.layers.Rescaling(
        255.0,
        name="restore_255"
    )(inputs)


    # --------------------------------------------------------
    # EFFICIENTNET
    # --------------------------------------------------------

    x = base_model(
        x,
        training=False
    )


    # --------------------------------------------------------
    # GLOBAL AVERAGE POOLING
    # --------------------------------------------------------

    x = tf.keras.layers.GlobalAveragePooling2D(
        name="global_average_pooling"
    )(x)


    # --------------------------------------------------------
    # BATCH NORMALIZATION
    # --------------------------------------------------------

    x = tf.keras.layers.BatchNormalization(
        name="head_batch_norm"
    )(x)


    # --------------------------------------------------------
    # DENSE 256
    # --------------------------------------------------------

    x = tf.keras.layers.Dense(
        256,
        activation="relu",
        name="dense_256"
    )(x)


    # --------------------------------------------------------
    # DROPOUT
    # --------------------------------------------------------

    x = tf.keras.layers.Dropout(
        0.45,
        name="dropout_45"
    )(x)


    # --------------------------------------------------------
    # DENSE 64
    # --------------------------------------------------------

    x = tf.keras.layers.Dense(
        64,
        activation="relu",
        name="dense_64"
    )(x)


    # --------------------------------------------------------
    # DROPOUT
    # --------------------------------------------------------

    x = tf.keras.layers.Dropout(
        0.30,
        name="dropout_30"
    )(x)


    # --------------------------------------------------------
    # OUTPUT
    # --------------------------------------------------------

    outputs = tf.keras.layers.Dense(
        1,
        activation="sigmoid",
        name="stress_output"
    )(x)


    # --------------------------------------------------------
    # CREATE MODEL
    # --------------------------------------------------------

    model = tf.keras.Model(
        inputs,
        outputs
    )


    print()
    print("Model architecture created.")

    print(
        "Model layers:",
        len(model.layers)
    )


    # ========================================================
    # TRY BEST WEIGHTS
    # ========================================================

    if os.path.exists(BEST_WEIGHTS_PATH):

        print()
        print("==============================================")
        print("LOADING BEST WEIGHTS")
        print("==============================================")


        try:

            model.load_weights(
                BEST_WEIGHTS_PATH
            )

            print()
            print("Best weights loaded successfully.")


        except Exception as e:

            print()
            print("Best weights could not be loaded.")

            print()
            print("ERROR:")
            print(e)

            print()
            print("Your best weights file does not match")
            print("the current model architecture.")

            print()
            print("The complete .keras model is required")
            print("for direct prediction.")


            print()
            print("==============================================")
            print("STOPPING")
            print("==============================================")

            exit()


# ============================================================
# MODEL READY
# ============================================================

print()
print("==============================================")
print("MODEL READY")
print("==============================================")

print(
    "Input:",
    model.input_shape
)

print(
    "Output:",
    model.output_shape
)


# ============================================================
# PREPROCESS THERMAL IMAGE
# ============================================================

def preprocess_thermal_frame(frame):

    # Resize
    frame = cv2.resize(
        frame,
        (
            IMG_SIZE,
            IMG_SIZE
        )
    )


    # Convert to float
    frame = frame.astype(
        np.float32
    )


    # Min-max normalization
    image_min = np.min(frame)

    image_max = np.max(frame)


    if image_max > image_min:

        frame = (
            frame - image_min
        ) / (
            image_max - image_min
        )

    else:

        frame = frame / 255.0


    # Add batch dimension
    frame = np.expand_dims(
        frame,
        axis=0
    )


    return frame


# ============================================================
# PREDICTION
# ============================================================

def predict_thermal_stress(frame):

    image = preprocess_thermal_frame(
        frame
    )


    prediction = model.predict(
        image,
        verbose=0
    )


    score = float(
        prediction[0][0]
    )


    if score >= THRESHOLD:

        status = "STRESS"

    else:

        status = "NON-STRESS"


    return status, score


# ============================================================
# OPEN CAMERA
# ============================================================

print()
print("==============================================")
print("OPENING THERMAL CAMERA")
print("==============================================")


camera = cv2.VideoCapture(
    CAMERA_INDEX
)


if not camera.isOpened():

    print()
    print("ERROR: Camera could not be opened.")

    print()
    print("Try changing:")
    print()
    print("CAMERA_INDEX = 0")
    print()
    print("to:")
    print()
    print("CAMERA_INDEX = 1")

    exit()


print()
print("Thermal camera opened successfully.")

print()
print("Prediction interval:")
print(
    CAPTURE_INTERVAL,
    "seconds"
)

print()
print("Press Q to exit.")


# ============================================================
# VARIABLES
# ============================================================

last_prediction_time = 0

status = "WAITING"

score = 0.0


# ============================================================
# LIVE MONITORING
# ============================================================

while True:

    ret, frame = camera.read()


    if not ret:

        print(
            "Could not read camera frame."
        )

        break


    current_time = time.time()


    # ========================================================
    # PREDICT EVERY 10 SECONDS
    # ========================================================

    if (
        current_time
        -
        last_prediction_time
        >=
        CAPTURE_INTERVAL
    ):

        print()
        print("----------------------------------------------")

        print(
            "Capturing thermal image..."
        )


        try:

            status, score = predict_thermal_stress(
                frame
            )


            print(
                "Stress Status:",
                status
            )


            print(
                "Stress Score:",
                round(
                    score,
                    4
                )
            )


        except Exception as e:

            print()
            print(
                "Prediction error:"
            )

            print(e)


        last_prediction_time = current_time


    # ========================================================
    # DISPLAY
    # ========================================================

    cv2.putText(
        frame,
        "THERMAL STRESS MONITORING",
        (
            20,
            40
        ),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.7,
        (
            255,
            255,
            255
        ),
        2
    )


    cv2.putText(
        frame,
        "Status: " + status,
        (
            20,
            80
        ),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.8,
        (
            255,
            255,
            255
        ),
        2
    )


    cv2.putText(
        frame,
        "Score: " + str(
            round(
                score,
                3
            )
        ),
        (
            20,
            120
        ),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.7,
        (
            255,
            255,
            255
        ),
        2
    )


    cv2.putText(
        frame,
        "Prediction every 10 seconds",
        (
            20,
            160
        ),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.6,
        (
            255,
            255,
            255
        ),
        2
    )


    # ========================================================
    # SHOW CAMERA
    # ========================================================

    cv2.imshow(
        "Thermal Stress Monitoring",
        frame
    )


    # ========================================================
    # KEYBOARD
    # ========================================================

    key = cv2.waitKey(
        1
    ) & 0xFF


    if key == ord("q"):

        break


# ============================================================
# CLOSE CAMERA
# ============================================================

camera.release()

cv2.destroyAllWindows()


print()
print("==============================================")
print("THERMAL MONITORING STOPPED")
print("==============================================")